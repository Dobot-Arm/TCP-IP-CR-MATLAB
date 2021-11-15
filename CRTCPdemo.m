slCharacterEncoding='UTF-8'

APIClient=tcpip('192.168.5.1',29999,'NetworkRole','client');
MoveClient=tcpip('192.168.5.1',30003,'NetworkRole','client');
stateClient = tcpip('192.168.5.1',30004,'NetworkRole','client');
%连接
set(stateClient,'InputBufferSize',1440);
set(stateClient,'Timeout',30);
set(APIClient,'InputBufferSize',100);
set(APIClient,'Timeout',30);

set(MoveClient,'InputBufferSize',100);
set(MoveClient,'Timeout',30);

fopen(stateClient);
fopen(APIClient);
fopen(MoveClient);

global stateDataArray;

stateTimer = timer('TimerFcn', {@TimerFcn1,stateClient}, 'Period', 2, 'ExecutionMode', 'fixedRate');

start(stateTimer);
messageInput='';
while(string(messageInput)~='quit')
    messageInput=input('CR MATLAB TCP-DEMO:','s');
    if messageInput=="help"
        fprintf("some one need help\n");
        fprintf("please input Dobot CR TCP-IP protocol command to control CR\n")
        fprintf("sucha as:\'EnableRobot\'\n");
        fprintf("input 'quit' to close demo\n")
        fprintf("input 'stauts' to look at robot status\n")
        fprintf("if you want to kown what comand can be used in this demo please input \'list\'\n")
    elseif strcmp(messageInput,'status')
        byteLen1=stateDataArray(1,1);
        byteLen2=stateDataArray(2,1);
        byteLen=byteLen1+byteLen2*256;
        fprintf("status array size len:%d\n",byteLen);
        robotMode="ROBOT_MODE_NO_CONTROLLER";
        switch stateDataArray(25,1)
            case -1
                robotMode="ROBOT_MODE_NO_CONTROLLER";
            case 0
                robotMode="ROBOT_MODE_DISCONNECTED";
            case 1
                robotMode="ROBOT_MODE_CONFIRM_SAFETY";
            case 2
                robotMode="ROBOT_MODE_BOOTING";
            case 3
                robotMode="ROBOT_MODE_POWER_OFF";
            case 4
                robotMode="ROBOT_MODE_POWER_ON";
            case 5
                robotMode="ROBOT_MODE_IDLE";
            case 6
                robotMode="ROBOT_MODE_BACKDRIVE";
            case 7
                robotMode="ROBOT_MODE_RUNNING";
            case 8
                robotMode="ROBOT_MODE_UPDATING_FIRMWARE";
            case 9
                robotMode="ROBOT_MODE_ERROR";
        end
        fprintf("Robot mode:%s\n",robotMode);
        fprintf("IO Input value:%d %d %d %d %d %d %d %d \n",stateDataArray(9,1),stateDataArray(10,1),stateDataArray(11,1),stateDataArray(12,1),stateDataArray(13,1),stateDataArray(14,1),stateDataArray(15,1),stateDataArray(16,1));
        fprintf("IO Output value:%d %d %d %d %d %d %d %d \n",stateDataArray(17,1),stateDataArray(18,1),stateDataArray(19,1),stateDataArray(20,1),stateDataArray(21,1),stateDataArray(22,1),stateDataArray(23,1),stateDataArray(24,1));
        fprintf("Speed scaling:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(72,1))),dec2hex(char(stateDataArray(71,1))),dec2hex(char(stateDataArray(70,1))),dec2hex(char(stateDataArray(69,1))),dec2hex(char(stateDataArray(68,1))),dec2hex(char(stateDataArray(67,1))),dec2hex(char(stateDataArray(66,1))),dec2hex(char(stateDataArray(65,1))))));
        fprintf("joint actual j1:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(440,1))),dec2hex(char(stateDataArray(439,1))),dec2hex(char(stateDataArray(438,1))),dec2hex(char(stateDataArray(437,1))),dec2hex(char(stateDataArray(436,1))),dec2hex(char(stateDataArray(435,1))),dec2hex(char(stateDataArray(434,1))),dec2hex(char(stateDataArray(433,1))))));
        fprintf("joint actual j2:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(448,1))),dec2hex(char(stateDataArray(447,1))),dec2hex(char(stateDataArray(446,1))),dec2hex(char(stateDataArray(445,1))),dec2hex(char(stateDataArray(444,1))),dec2hex(char(stateDataArray(443,1))),dec2hex(char(stateDataArray(442,1))),dec2hex(char(stateDataArray(441,1))))));
        fprintf("joint actual j3:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(456,1))),dec2hex(char(stateDataArray(455,1))),dec2hex(char(stateDataArray(454,1))),dec2hex(char(stateDataArray(453,1))),dec2hex(char(stateDataArray(452,1))),dec2hex(char(stateDataArray(451,1))),dec2hex(char(stateDataArray(450,1))),dec2hex(char(stateDataArray(449,1))))));
        fprintf("joint actual j4:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(464,1))),dec2hex(char(stateDataArray(463,1))),dec2hex(char(stateDataArray(462,1))),dec2hex(char(stateDataArray(461,1))),dec2hex(char(stateDataArray(460,1))),dec2hex(char(stateDataArray(459,1))),dec2hex(char(stateDataArray(458,1))),dec2hex(char(stateDataArray(457,1))))));
        fprintf("joint actual j5:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(472,1))),dec2hex(char(stateDataArray(471,1))),dec2hex(char(stateDataArray(470,1))),dec2hex(char(stateDataArray(469,1))),dec2hex(char(stateDataArray(468,1))),dec2hex(char(stateDataArray(467,1))),dec2hex(char(stateDataArray(466,1))),dec2hex(char(stateDataArray(465,1))))));
        fprintf("joint actual j6:%d\n",hex2num(strcat(dec2hex(char(stateDataArray(480,1))),dec2hex(char(stateDataArray(479,1))),dec2hex(char(stateDataArray(478,1))),dec2hex(char(stateDataArray(477,1))),dec2hex(char(stateDataArray(476,1))),dec2hex(char(stateDataArray(475,1))),dec2hex(char(stateDataArray(474,1))),dec2hex(char(stateDataArray(473,1))))));
        
        fprintf("cartesian actual x:%8.4f\n",hex2num(strcat(dec2hex(char(stateDataArray(632,1))),dec2hex(char(stateDataArray(631,1))),dec2hex(char(stateDataArray(630,1))),dec2hex(char(stateDataArray(629,1))),dec2hex(char(stateDataArray(628,1))),dec2hex(char(stateDataArray(629,1))),dec2hex(char(stateDataArray(628,1))),dec2hex(char(stateDataArray(625,1))))));
        fprintf("cartesian actual y:%8.4f\n",hex2num(strcat(dec2hex(char(stateDataArray(640,1))),dec2hex(char(stateDataArray(639,1))),dec2hex(char(stateDataArray(638,1))),dec2hex(char(stateDataArray(637,1))),dec2hex(char(stateDataArray(636,1))),dec2hex(char(stateDataArray(635,1))),dec2hex(char(stateDataArray(634,1))),dec2hex(char(stateDataArray(633,1))))));
        fprintf("cartesian actual z:%8.4f\n",hex2num(strcat(dec2hex(char(stateDataArray(648,1))),dec2hex(char(stateDataArray(647,1))),dec2hex(char(stateDataArray(646,1))),dec2hex(char(stateDataArray(645,1))),dec2hex(char(stateDataArray(644,1))),dec2hex(char(stateDataArray(643,1))),dec2hex(char(stateDataArray(642,1))),dec2hex(char(stateDataArray(641,1))))));
        fprintf("cartesian actual rx:%8.4f\n",hex2num(strcat(dec2hex(char(stateDataArray(656,1))),dec2hex(char(stateDataArray(655,1))),dec2hex(char(stateDataArray(654,1))),dec2hex(char(stateDataArray(653,1))),dec2hex(char(stateDataArray(652,1))),dec2hex(char(stateDataArray(651,1))),dec2hex(char(stateDataArray(650,1))),dec2hex(char(stateDataArray(649,1))))));
        fprintf("cartesian actual ry:%8.4f\n",hex2num(strcat(dec2hex(char(stateDataArray(664,1))),dec2hex(char(stateDataArray(663,1))),dec2hex(char(stateDataArray(662,1))),dec2hex(char(stateDataArray(661,1))),dec2hex(char(stateDataArray(660,1))),dec2hex(char(stateDataArray(659,1))),dec2hex(char(stateDataArray(658,1))),dec2hex(char(stateDataArray(657,1))))));
        fprintf("cartesian actual rz:%8.4f\n",hex2num(strcat(dec2hex(char(stateDataArray(672,1))),dec2hex(char(stateDataArray(671,1))),dec2hex(char(stateDataArray(670,1))),dec2hex(char(stateDataArray(669,1))),dec2hex(char(stateDataArray(668,1))),dec2hex(char(stateDataArray(667,1))),dec2hex(char(stateDataArray(666,1))),dec2hex(char(stateDataArray(665,1))))));
    
    elseif messageInput=="list"
        fprintf("the comand you can use in this demo\n");
        fprintf("EnableRobot\n");
        fprintf("DisableRobot\n");
        fprintf("ClearError\n");
        fprintf("ResetRobot\n");
        fprintf("SpeedFactor\n");
        fprintf("User\n");
        fprintf("Tool\n");
        fprintf("RobotMode\n");
        fprintf("PayLoad\n");
        fprintf("DO\n");
        fprintf("DOExecute\n");
        fprintf("ToolDO\n");
        fprintf("ToolDOExecute\n");
        fprintf("AO\n");
        fprintf("AOExecute\n");
        fprintf("AccJ\n");
        fprintf("AccL\n");
        fprintf("SpeedJ\n");
        fprintf("SpeedL\n");
        fprintf("Arch\n");
        fprintf("CP\n");
        fprintf("LimZ\n");
        fprintf("SetArmOrientation\n");
        fprintf("PowerOn\n");
        fprintf("RunScript\n");
        fprintf("StopScript\n");
        fprintf("PauseScript\n");
        fprintf("ContinueScript\n");
        fprintf("SetSafeSkin\n");
        fprintf("SetObstacleAvoid\n");
        fprintf("GetTraceStartPose\n");
        fprintf("GetPathStartPose\n");
        fprintf("PositiveSolution\n");
        fprintf("InverseSolution\n");
        fprintf("SetCollisionLevel\n");
        fprintf("HandleTrajPoints\n");
        fprintf("GetSixForceData\n");
        fprintf("GetAngle\n");
        fprintf("GetPose\n");
        fprintf("EmergencyStop\n");
        fprintf("Sync\n");
        fprintf("Auto\n");
        fprintf("Manual\n");
        fprintf("MovJ\n");
        fprintf("MovL\n");
        fprintf("JointMovJ\n");
        fprintf("RelMovJ\n");
        fprintf("RelMovL\n");
        fprintf("MovLIO\n");
        fprintf("MovJIO\n");
        fprintf("Arc\n");
        fprintf("Circle\n");
        fprintf("ServoJ\n");
        fprintf("ServoP\n");
        fprintf("MoveJog\n");
        fprintf("StartTrace\n");
        fprintf("StartPath\n");
        fprintf("StartFCTrace\n");
    elseif messageInput =="MovJ"|| messageInput =="MovL"||messageInput =="ServoP"
        coordinate=input('need input cartesian coordinates such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
        enableVar=char('EnableRobot()');
        fwrite(APIClient,enableVar,'char');
        pause(5);
        movJEnableRes=fread(APIClient,APIClient.BytesAvailable);
        movJEnableResStr=char(movJEnableRes(1:end));
        if strcmp(movJEnableResStr.',"-1")
            %do movJ
            messageInput=strcat(messageInput,"(");
            messageInput=strcat(messageInput,coordinate);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
        end
    elseif messageInput =="JointMovJ"||messageInput =="ServoJ"
        coordinate=input('need input joint coordinates such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
        enableVar=char('EnableRobot()');
        fwrite(APIClient,enableVar,'char');
        pause(5);
        movJEnableRes=fread(APIClient,APIClient.BytesAvailable);
        movJEnableResStr=char(movJEnableRes(1:end));
        if strcmp(movJEnableResStr.',"-1")
            %do movJ
            messageInput=strcat(messageInput,"(");
            messageInput=strcat(messageInput,coordinate);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
        end
    elseif messageInput =="RelMovJ"|| messageInput =="RelMovL"
        coordinate=input('need input offset coordinates such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
        enableVar=char('EnableRobot()');
        fwrite(APIClient,enableVar,'char');
        pause(5);
        movJEnableRes=fread(APIClient,APIClient.BytesAvailable);
        movJEnableResStr=char(movJEnableRes(1:end));
        if strcmp(movJEnableResStr.',"-1")
            %do movJ
            messageInput=strcat(messageInput,"(");
            messageInput=strcat(messageInput,coordinate);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
        end
    elseif messageInput =="MovJIO"|| messageInput =="MovLIO"
        coordinate=input('need input cartesian coordinates such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
        mode=input('need input mode(0,1):','s');
        distance=input('need input distance:','s');
        index=input('need input index(1-24):','s');
        status=input('need input stauts(0-low , 1-high ,):','s');
        enableVar=char('EnableRobot()');
        fwrite(APIClient,enableVar,'char');
        pause(5);
        movJEnableRes=fread(APIClient,APIClient.BytesAvailable);
        movJEnableResStr=char(movJEnableRes(1:end));
        if strcmp(movJEnableResStr.',"-1")
            %do movJ
            messageInput=strcat(messageInput,"(");
            messageInput=strcat(messageInput,coordinate);
            messageInput=strcat(messageInput,",");
            messageInput=strcat(messageInput,mode);
            messageInput=strcat(messageInput,",");
            messageInput=strcat(messageInput,distance);
            messageInput=strcat(messageInput,",");
            messageInput=strcat(messageInput,index);
            messageInput=strcat(messageInput,",");
            messageInput=strcat(messageInput,status);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
        end
    elseif messageInput =="Arch"||messageInput =="Circle"
        if messageInput =="Circle"
            count=input('need input count:','s');
        end
        coordinate1=input('need input cartesian coordinates 1 such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
        coordinate2=input('need input cartesian coordinates 2 such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
        enableVar=char('EnableRobot()');
        fwrite(APIClient,enableVar,'char');
        pause(5);
        movJEnableRes=fread(APIClient,APIClient.BytesAvailable);
        movJEnableResStr=char(movJEnableRes(1:end));
        if strcmp(movJEnableResStr.',"-1")
            %do movJ
            if messageInput =="Circle"
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,count);
                messageInput=strcat(messageInput,",");
            else
                messageInput=strcat(messageInput,"(");
            end
            messageInput=strcat(messageInput,coordinate1);
            messageInput=strcat(messageInput,",");
            messageInput=strcat(messageInput,coordinate2);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
        end
    elseif messageInput =="MoveJog"
        mode=input('need input MoveJog mode(j1+,j2+,j3+,j4+,j5+,j6+,j1-,j2-,j3-,j4-,j5-,j6-\n,x+,y+,z+,rx+,ry+,rz+,x-,y-,z-,rx-,ry-,rz-):','s');
        manualVar=char('Manual()');
        fwrite(APIClient,manualVar,'char');
        pause(1);
        fprintf("MoveJog manual byte available:%d",APIClient.BytesAvailable);
        manualVarRes=fread(APIClient,APIClient.BytesAvailable);
        manualVarResStr=char(manualVarRes(1:end));
        manualVarResStr=manualVarResStr.';
        if strcmp(manualVarResStr,"Manual()")
            %do movJ
            messageInput=strcat(messageInput,"(");
            messageInput=strcat(messageInput,mode);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
            stopInput=input('If you want to stop or quit MoveJog,please click enter key','s');
            fwrite(MoveClient,char('MoveJog()'),'char');
        end
    elseif messageInput =="StartPath"|| messageInput =="StartFCTrace"|| messageInput =="StartTrace"
        path=input('need input trace file path:','s');
        enableVar=char('EnableRobot()');
        fwrite(APIClient,enableVar,'char');
        pause(5);
        movJEnableRes=fread(APIClient,APIClient.BytesAvailable);
        movJEnableResStr=char(movJEnableRes(1:end));
        if strcmp(movJEnableResStr.',-1)
            %do movJ
            messageInput=strcat(messageInput,"(");
            messageInput=strcat(messageInput,path);
            messageInput=strcat(messageInput,")");
            fwrite(MoveClient,char(messageInput),'char');
        end
    elseif string(messageInput) ~='quit'
        isUnkonwnCmd=0;
        switch messageInput
            case 'EnableRobot'
                messageInput=strcat(messageInput,"()");
            case 'DisableRobot'
                messageInput=strcat(messageInput,"()");
            case 'ClearError'
                messageInput=strcat(messageInput,"()");
            case 'ResetRobot'
                messageInput=strcat(messageInput,"()");
            case 'RobotMode'
                messageInput=strcat(messageInput,"()");
            case 'SpeedFactor'
                speedRatio=input('need input speed Ratio(1-99):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,speedRatio);
                messageInput=strcat(messageInput,")");
            case 'User'
                index=input('need input user coordinate index (0-9):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,")");
            case 'Tool'
                index=input('need input tool coordinate index (0-9):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,")");
            case 'PayLoad'
                weight=input('need input payLoad weight(0-7 kg):','s');
                inertia=input('need input payLoad inertia():','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,weight);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,inertia);
                messageInput=strcat(messageInput,")");
            case 'DO'
                index=input('need input IO index(1-24):','s');
                value=input('need input status value(1:high 0:low):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'DOExecute'
                index=input('need input IO index(1-24):','s');
                value=input('need input status value(1:high 0:low):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'ToolDO'
                index=input('need input IO index(1-24):','s');
                value=input('need input status value(1:high 0:low):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'ToolDOExecute'
                index=input('need input IO index(1-24):','s');
                value=input('need input status value(1:high 0:low):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'AO'
                index=input('need input IO index(1-2):','s');
                value=input('need input status value(1:high 0:low):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'AOExecute'
                index=input('need input IO index(1-2):','s');
                value=input('need input status value(1:high 0:low):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,",");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'AccJ'
                ratio=input('need input acceleration ratio:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,ratio);
                messageInput=strcat(messageInput,")");
            case 'AccL'
                ratio=input('need input acceleration ratio:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,ratio);
                messageInput=strcat(messageInput,")");
            case 'SpeedJ'
                ratio=input('need input speed ratio:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,ratio);
                messageInput=strcat(messageInput,")");
            case 'SpeedL'
                ratio=input('need input speed ratio:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,ratio);
                messageInput=strcat(messageInput,")");
            case 'Arch'
                index=input('need input arch setting index (0-9):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,index);
                messageInput=strcat(messageInput,")");
            case 'CP'
                ratio=input('need input cp ratio(1-100):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,ratio);
                messageInput=strcat(messageInput,")");
            case 'LimZ'
                zValue=input('need input limit value:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,zValue);
                messageInput=strcat(messageInput,")");
            case 'SetArmOrientation'
                rdnCFG=input('need input R D N CFG value such as:1,-1,1,1(split by ,):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,rdnCFG);
                messageInput=strcat(messageInput,")");
            case 'PowerOn'
                messageInput=strcat(messageInput,"()");
            case 'RunScript'
                messageInput=strcat(messageInput,"()");
            case 'StopScript'
                messageInput=strcat(messageInput,"()");
            case 'PauseScript'
                messageInput=strcat(messageInput,"()");
            case 'ContinueScript'
                messageInput=strcat(messageInput,"()");
            case 'SetSafeSkin'
                value=input('need input status value(0-off,1-on):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'SetObstacleAvoid'
                value=input('need input status value(0-off,1-on):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'GetTraceStartPose'
                traceName=input('need input traceName:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,traceName);
                messageInput=strcat(messageInput,")");
            case 'GetPathStartPose'
                traceName=input('need input traceName:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,traceName);
                messageInput=strcat(messageInput,")");
            case 'PositiveSolution'
                coordinate=input('need input joint coordinates such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,coordinate);
                messageInput=strcat(messageInput,")");
            case 'InverseSolution'
                coordinate=input('need input cartesian coordinates such as 0.56,26.65,160.23,-50.14,68.923 (split by ,):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,coordinate);
                messageInput=strcat(messageInput,")");
            case 'SetCollisionLevel'
                value=input('need input level value(0-5):','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,value);
                messageInput=strcat(messageInput,")");
            case 'HandleTrajPoints'
                traceName=input('need input traceName:','s');
                messageInput=strcat(messageInput,"(");
                messageInput=strcat(messageInput,traceName);
                messageInput=strcat(messageInput,")");
            case 'GetSixForceData'
                messageInput=strcat(messageInput,"()");
            case 'GetAngle'
                messageInput=strcat(messageInput,"()");
            case 'GetPose'
                messageInput=strcat(messageInput,"()");
            case 'EmergencyStop'
                messageInput=strcat(messageInput,"()");
            case 'Sync'
                messageInput=strcat(messageInput,"()");
            case 'Auto'
                messageInput=strcat(messageInput,"()");
            case 'Manual'
                messageInput=strcat(messageInput,"()");
            otherwise
                isUnkonwnCmd=1;
        end
        if isUnkonwnCmd
            isUnkonwnCmd=0;
            fprintf("unkonwn comand you can input \'help\' for help\n");
        else
            messageInput=char(messageInput);
            fwrite(APIClient,messageInput,'char');
            if strcmp(messageInput,'EnableRobot()')
                fprintf("API %s need wait 5 seconds\n",messageInput);
                pause(5);
            else
                pause(1);
            end
            if APIClient.BytesAvailable>0
                res=fread(APIClient,APIClient.BytesAvailable);
                resStr=char(res(1:end));
                fprintf("API %s Res:%s\n",messageInput,resStr.');
            else
                fprintf("API %s no reply\n",messageInput);
            end
            messageInput="";
            
        end
    end
end

fclose(stateClient);
fclose(APIClient);
fclose(MoveClient);
stop(stateTimer);

clear stateTimer;
clear APIClient;
clear MoveClient;
clear stateClient;

function TimerFcn1(obj,event,tInfo)
global stateDataArray
%fprintf("do timer fnc1:%d\n",stateDataArray);
%你自己的操作
if tInfo.BytesAvailable>0
    stateDataArray = fread(tInfo,tInfo.BytesAvailable,'uint8');
end
%  fprintf("connect info:%d\n",A)
end
