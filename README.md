# momento
Motion correction application using on-device AI, POSTECH EECE492-01 team project.

##  Introduction
Application that extracts a user's pose from smartphone camera with on-device AI in realtime and compares it to an expert's pose. And then calculate user's pose accuracy. This app can be applied to exercising alone without personal training and practicing dancing.

Pose estimation runs in on-device environment. However it was difficult to implement the motion scoring algorithm using dart because of lack of mathematical operations. So we implemented the algorithm using python and numpy. And then serve this algorithm using Flask server, so that the app can use this algorithm by calling API. 

Check details about whole project in
</br> - poster KR ver. (Eng version will be uploaded soon)

### App
Check entire app code in momentong directory.
<br/> App Full Demo

<img src="https://github.com/junsoo37/momento/blob/master/demo.gif" height="500"/>


### Motion scoring algorithm
Check motion scoring code in server directory.
</br>
The motion scoring algorithms is based on ["Efficient Body Motion Quantification and Similarity Evaluation Using 3-D Joints Skeleton Coordinates"](https://ieeexplore.ieee.org/document/8727745) in IEEE Transactions on Systems, Man, and Cybernetics: Systems (2021).
</br> We implemented the algorithm in the paper by modifying for our project.


## Tech Stack
- App: Flutter
- Motion scoring algorithm(server): python, numpy, Flask
- Pose Estimation model: MoveNet (Failed to apply 3D VIBE model in on-device environment.. But keep trying to apply it)


## Team with
- Jaejin Kim (kimjaejin@postech.ac.kr)
- Jiwon Park (jw0815@postech.ac.kr)
