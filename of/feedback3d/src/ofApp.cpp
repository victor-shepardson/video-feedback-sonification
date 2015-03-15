#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    params.setName("params");
	params.add(fb.set("fb",2));
	params.add(gen.set("gen",1));
	params.add(tblur.set("tblur",.9));
	params.add(sblur.set("sblur",.5));
	params.add(warp.set("warp",.3));
	params.add(perm.set("perm",-1));
    params.add(bound.set("bound", 2));
    params.add(record.set("record", 0));

	gui.setup(params);
	sync.setup((ofParameterGroup&)gui.getParameter(),6666,"localhost",6667);

    movieWidth = 2*11; movieHeight = 2*18;
    sliceX = 1; sliceY = 1;

    ofEnableDataPath();

    ofSetWindowShape(movieWidth, movieHeight);
    ofEnableArbTex();

    shader.load(ofToDataPath("feedback3d"));

    color_img.allocate(movieWidth, movieHeight, OF_IMAGE_COLOR_ALPHA);

    fbo1.allocate(movieWidth, movieHeight, GL_RGBA);
    fbo2.allocate(movieWidth, movieHeight, GL_RGBA);

    fbo1.begin();
    ofBackground(0);
    fbo1.end();

    fbo2.begin();
    ofBackground(0);
    fbo2.end();

    frame = 0;

    save_prefix = ofGetTimestampString();
    //ofSystem("mkdir "+save_prefix);
    save_prefix+='/';
    save_suffix = ".png";

}


//--------------------------------------------------------------
void ofApp::update(){
    sync.update();
    //color_img.setFromPixels(camera.getPixelsRef());

}

//--------------------------------------------------------------
void ofApp::draw(){

    ofBackground(0);

    fbo1.begin();
    shader.begin();
    shader.setUniformTexture("image1", color_img.getTextureReference(), 0);
    shader.setUniformTexture("image2", fbo2.getTextureReference(), 1);
    shader.setUniform1f("fb", fb.get());
    shader.setUniform1f("tblur", tblur.get());
    shader.setUniform1f("sblur", sblur.get());
    shader.setUniform1f("gen", gen.get());
    shader.setUniform1f("frame", frame++);
    shader.setUniform1f("warp", warp.get());
    shader.setUniform1f("perm", perm.get());
    shader.setUniform1i("bound", bound.get());
    shader.setUniform2i("size", movieWidth, movieHeight);
    shader.setUniform2f("slice", sliceX, sliceY);

    color_img.draw(0, 0);

    shader.end();
    fbo1.end();

    fbo1.draw(0, 0);

    ofPixels pixels;
    fbo1.readToPixels(pixels);
    fbo2.begin();
    ofImage img;
    img.allocate(movieWidth, movieHeight, OF_IMAGE_COLOR_ALPHA);
    img.setFromPixels(pixels);
    img.draw(0, 0);
    if(record)
        img.saveImage(save_prefix+ofToString(frame, 5, '0')+save_suffix, OF_IMAGE_QUALITY_BEST);
    fbo2.end();

}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){

}
