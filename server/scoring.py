from flask import Flask, request
import numpy as np
from scipy.stats import norm


class Node:
    def __init__(self, index, parent):
        self.parent = parent
        self.index = index

def ConvertMatrixToMoveNetSkeleton(Nodearr):
    Nodearr[0] = Node(0, 0)  # origin

    Nodearr[1] = Node(1, 0)  # 5 left shoulder
    Nodearr[7] = Node(7, 0)  # 11 right shoulder
    Nodearr[8] = Node(8, 0)  # 12 left hip
    Nodearr[2] = Node(2, 0)  # 6 right hip

    Nodearr[3] = Node(3, 1)  # 7 left elbow
    Nodearr[5] = Node(5, 3)  # 9 left wrist

    Nodearr[4] = Node(4, 2)  # 8 rigth elbow
    Nodearr[6] = Node(6, 4)  # 10 right wrist

    Nodearr[9] = Node(9, 7)  # 13 left knee
    Nodearr[11] = Node(11, 9)  # 15 left ankle

    Nodearr[10] = Node(10, 8)  # 14 right knee
    Nodearr[12] = Node(12, 10)  # 16 right ankle

    return Nodearr


def RotationAngles(matrix):

    r11, r12, r13 = matrix[0]
    r21, r22, r23 = matrix[1]
    r31, r32, r33 = matrix[2]

    theta1 = np.arctan(-r23 / r33)
    theta2 = np.arctan(-r13 * np.cos(theta1))
    theta3 = np.arctan(-r12 / r11)

    t1 = np.array([theta1, 0, 0])
    t2 = np.array([0, theta2, 0])
    t3 = np.array([0, 0, theta3])

    return t1, t2, t3

def CalculateAngle(A, B, C):
    BA = A - B
    BC = C - B

    dot_product = np.dot(BA, BC)
    magnitude_product = np.linalg.norm(BA) * np.linalg.norm(BC)

    angle_rad = np.arccos(dot_product / magnitude_product)
    #angle_deg = np.degrees(angle_rad)

    return angle_rad


def getTransformationMatrix(matrix_prev, matrix_curr, matrix_next, is_global=1):

    centroid1 = (matrix_prev + matrix_curr) / 2
    centroid2 = (matrix_curr + matrix_next) / 2

    matrix1 = (matrix_prev - centroid1).reshape(-1, 1)
    matrix2 = (matrix_curr - centroid2).reshape(1, -1)
    matrix3 = (matrix_curr - centroid1).reshape(-1, 1)
    matrix4 = (matrix_next - centroid2).reshape(1, -1)

    H = matrix1.dot(matrix2) + matrix3.dot(matrix4)

    U, S, V = np.linalg.svd(H)
    R = np.dot(V, U.T)  # R = (3, 3)
    t = -R.dot(centroid1) + centroid2  # t = (3, 1)

    arr = np.array([0, 0, 0, 1])

    tm = np.concatenate((R, t.reshape(-1, 1)), axis=1)
    tm = np.concatenate((tm, arr.reshape(1, -1)), axis=0)

    if (is_global):
        return tm, R, t
    else:
        return tm


def Quantification(tensor, total_frames, num_joints, Nodearr):

    g_motion = np.empty((total_frames - 1, num_joints), dtype=object)
    l_motion = np.empty((total_frames - 1, num_joints), dtype=object)
    angles = np.empty((total_frames - 1, 8), dtype=object)

    for i in range(1, total_frames - 1):

        for j in range(num_joints):

            gm, R, t = getTransformationMatrix(tensor[i-1][j],
                                               tensor[i][j], tensor[i+1][j], is_global=1)
            gm_theta1, gm_theta2, gm_theta3 = RotationAngles(R)

            if j == 0 or Nodearr[j].parent == 0:
                lm = gm

            else:
                k = Nodearr[j].parent
                sub_lm = np.identity(4)

                while(k != 0):
                    k = Nodearr[k].parent
                    sub_lm = sub_lm.dot(getTransformationMatrix(
                        tensor[i-1][k], tensor[i][k], tensor[i+1][k], is_global=0))

                lm = gm * np.linalg.inv(sub_lm)

            lm_R = lm[0:3, 0:3].copy()
            lm_t = lm[0:3, 3].copy()

            lm_theta1, lm_theta2, lm_theta3 = RotationAngles(lm_R)

            g_result = np.vstack((gm_theta1, gm_theta2, gm_theta3, t))
            l_result = np.vstack((lm_theta1, lm_theta2, lm_theta3, lm_t))

            g_motion[i][j] = np.copy(g_result)
            l_motion[i][j] = np.copy(l_result)

        # angle between limbs
        a1 = CalculateAngle(tensor[i][3], tensor[i][1], tensor[1][7]) # left: elbow - shoulder - hip
        a2 = CalculateAngle(tensor[i][8], tensor[i][2], tensor[i][4]) # right: elbow - shoulder - hip
        a3 = CalculateAngle(tensor[i][1], tensor[i][7], tensor[i][9]) # left: shoulder - hip - knee
        a4 = CalculateAngle(tensor[i][2], tensor[i][8], tensor[i][10]) # right: shoulder - hip - knee
        a5 = CalculateAngle(tensor[i][1], tensor[i][3], tensor[i][5]) # left: shoulder - elbow - wrist
        a6 = CalculateAngle(tensor[i][2], tensor[i][4], tensor[i][6]) # right: shoulder - elbow - wrist
        a7 = CalculateAngle(tensor[i][7], tensor[i][9], tensor[i][11]) # left: hip - knee - ankle
        a8 = CalculateAngle(tensor[i][8], tensor[i][10], tensor[i][12]) # right: hip - knee - ankle

        angles[i] = np.array([a1, a2, a3, a4, a5, a6, a7, a8])

    return g_motion, l_motion, angles


def Distance(matrix1, matrix2):
    # print(matrix1)
    # print(matrix2)

    d_theta = np.linalg.norm(matrix1[:][:3] - matrix2[:][:3])
    d_trans = np.linalg.norm(matrix1[:][3] - matrix2[:][3])

    return d_theta, d_trans


def MatrixNormalize(matrix, origin):  # matrix = (N_joints, 3), origin = (3, )
    length = len(matrix)
    result = []

    for i in range(length):
        result.append(matrix[i] - origin)

    return result


# Nodearr is length 13 Node-type array
def Comparsion(tensor1, tensor2, total_frames, num_joints, Nodearr):

    if total_frames < 3:
        print("lack of frame")
        return -1

    for i in range(total_frames):
        #tensor1[i] = MatrixNormalize(
            #tensor1[i], origin=((tensor1[i][1] + tensor1[i][2] + tensor1[i][7] + tensor1[i][8]) / 4))

        tensor1[i] = MatrixNormalize(
            tensor1[i], origin=tensor1[i][0])
        tensor2[i] = MatrixNormalize(
            tensor2[i], origin=tensor2[i][0])

    g_motion1, l_motion1, angles1 = Quantification(
        tensor1, total_frames, num_joints, Nodearr)
    g_motion2, l_motion2, angles2 = Quantification(
        tensor2, total_frames, num_joints, Nodearr)

    #print("g_motion1: ", len(g_motion1))

    total_score = 0

    gm_theta_score = 1.5 # 13
    gm_translation_score = 0.6
    lm_theta_score = 0.75
    lm_translation_score = 0.3
    each_angle_score = 8

    gm_theata_threshold = 1.4
    gm_translation_threshold = 0.4
    lm_theta_threshold = 1.4
    lm_translation_threshold = 0.4
    each_angle_threshold = 0.33

    result_theta = []
    result_trans = []

    for i in range(1, total_frames - 1):
        gm_score = 0
        lm_score = 0
        angle_score = 0
        frame_score = 0

        for j in range(num_joints):

            g_dth, g_dt = Distance(g_motion1[i][j], g_motion2[i][j])
            l_dth, l_dt = Distance(l_motion1[i][j], l_motion2[i][j])

            if g_dth < gm_theata_threshold:
                gm_score += gm_theta_score

            if g_dt < gm_translation_threshold:
                gm_score += gm_translation_score

            if l_dth < lm_theta_threshold:
                lm_score += lm_theta_score

            if l_dt < lm_translation_threshold:
                lm_score += lm_translation_score

            #print("global: ",g_dth, g_dt)
            #print("local: ", g_dth, l_dt)

            result_theta.append(g_dth)
            result_trans.append(l_dt)

            #g_total += g_dt
            #l_total += l_dt

        for k in range(8):
            angle_dt = abs(angles1[i][k] - angles2[i][k])
            #print("angle_dt: ", angle_dt)

            if angle_dt < each_angle_threshold:
                angle_score += each_angle_score

            #angle_total += angle_dt

        #print(gm_score, lm_score, angle_score)

        # if angle_score > 32:
        #     frame_score = gm_score + lm_score + angle_score
        # else:
        #     frame_score = (gm_score + lm_score + angle_score) / 2

        frame_score = gm_score + lm_score + angle_score
        total_score += frame_score

    return min(round((total_score / (total_frames - 2)) * 1.0, 1), 100.0)


def CreateRandomMatrix(total_frames, num_of_joints):
    matrix1 = np.random.rand(total_frames, num_of_joints, 2)
    matrix2 = np.random.rand(total_frames, num_of_joints, 2)
    #zeros = np.zeros((total_frames, num_of_joints, 1))

    #matrix1 = np.concatenate((matrix1, zeros), axis=2)
    #matrix2 = np.concatenate((matrix2, zeros), axis=2)

    return matrix1, matrix2


def ZtoPercentile(z_score):
    percentile = norm.cdf(z_score) * 100
    return percentile


def GetScore(total_frames, mat1, mat2, num_joints = 13):

    Nodearr = np.empty(num_joints, dtype=Node)
    Nodearr = ConvertMatrixToMoveNetSkeleton(Nodearr)
    # mat1, mat2 = CreateRandomMatrix(total_frames, num_joints)

    # Comparsion
    score = Comparsion(mat1, mat2, total_frames, num_joints, Nodearr)

    print(score)
    return score


app = Flask(__name__)

total_frames = None
tensor1 = None
tensor2 = None

@app.route('/api', methods = ['POST'])
def query_tensor():
    data = request.get_json()
    total_frames = data.get('total_frames')

    tensor1 = np.array(data.get('tensor1'))
    tensor2 = np.array(data.get('tensor2'))

    origin_data1 = (tensor1[:, [0, 1, 6, 7]].mean(axis=1)).reshape(-1, 1, 2)
    origin_data2 = (tensor2[:, [0, 1, 6, 7]].mean(axis=1)).reshape(-1, 1, 2)

    tensor1 = np.concatenate((origin_data1, tensor1), axis=1)  # (total_frames, 13, 2)
    tensor2 = np.concatenate((origin_data2, tensor2), axis=1)  # (total_frames, 13, 2)

    # Add an extra column of zeros to tensor1 and tensor2
    tensor1 = np.concatenate((tensor1, np.zeros((total_frames, 13, 1))), axis=2)  # (total_frames, 13, 3)
    tensor2 = np.concatenate((tensor2, np.zeros((total_frames, 13, 1))), axis=2)  # (total_frames, 13, 3)

    score = GetScore(total_frames, tensor1, tensor2)

    return str(score)

if __name__ == "__main__":
    app.run()
