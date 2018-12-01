# Object Detection using Matlab
#### Four object detection algorithms in one program. 

Object detection and tracking in a video doesn't need the help of deep learning. The four algorithms implemented in this script are Basic Background Subtraction (BS), Adaptive Background Subtraction (ABS), Simple Frame Differencing (SFD), and Persistent Frame Differencing (PFD) provide robust, stable results in a variety of scenes. 

### Running

After downloading the script and example data into a Matlab enviroment, open up the script and edit the second and third lines to use your own data. The current code will work with the given example data (in /Project3-DataSets/DataSets). Executing the code will generate a folder for each video in /Outputs of a jpeg image for each frame of the scene.  

To render these frames, use ffmpeg in your console by executing
'''
ffmpeg -framerate 30 -i {output folder path}\{ImageSet}%04d.jpg -vf “scale=trunc(iw/2)*2:trunc(ih/2)*2” -an {ImageSet}_Movie.mp4
'''

Here's an exmaple frame 
![alt text][examp]

This project was done in a group for CMPEN 454

[examp]: https://github.com/dreeseaw/ObjectDetection/example.jpg
