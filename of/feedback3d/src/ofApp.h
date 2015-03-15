#pragma once

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxGui.h"
#include "ofxOscParameterSync.h"


class ofApp : public ofBaseApp{

    public:
        void setup();
        void update();
        void draw();

        void keyPressed(int key);
        void keyReleased(int key);
        void mouseMoved(int x, int y );
        void mouseDragged(int x, int y, int button);
        void mousePressed(int x, int y, int button);
        void mouseReleased(int x, int y, int button);
        void windowResized(int w, int h);
        void dragEvent(ofDragInfo dragInfo);
        void gotMessage(ofMessage msg);

        ofParameterGroup params;
        ofParameter<float> fb;
        ofParameter<float> tblur;
        ofParameter<float> sblur;
        ofParameter<float> gen;
        ofParameter<float> warp;
        ofParameter<float> perm;
        ofParameter<int> bound;
        ofParameter<int> record;

        ofxOscParameterSync sync;

        ofxPanel gui;

        ofVideoGrabber camera;
        ofImage color_img;

        ofFbo fbo1, fbo2;
        int frame;
        ofShader shader;

        int movieWidth, movieHeight;
        int sliceX, sliceY;

        string save_prefix, save_suffix;

};
