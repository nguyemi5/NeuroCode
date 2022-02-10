v = VideoReader('\\neurodata2\Large data\Video data\MonitoringVideokompHP\camA\camA__23431782__20210225_144720284.mp4');
v.Duration
v.VideoFormat
v.FrameRate
%%
pv = read(v, [1 100]);
%%
vw = VideoWriter('videopartIAviGrey', 'Indexed AVI');
open(vw);
writeVideo(vw, pv(:,:,1,:));
close(vw);
