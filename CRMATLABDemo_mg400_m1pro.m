classdef CRMATLABDemo_mg400 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        LogPanel                    matlab.ui.container.Panel
        LogTextArea                 matlab.ui.control.TextArea
        FeedbackPanel               matlab.ui.container.Panel
        CurrentSpeedRatioLabel      matlab.ui.control.Label
        RobotModeLabel              matlab.ui.control.Label
        rText                       matlab.ui.control.Label
        zText                       matlab.ui.control.Label
        yText                       matlab.ui.control.Label
        xText                       matlab.ui.control.Label
        J4Text                      matlab.ui.control.Label
        J3Text                      matlab.ui.control.Label
        J2Text                      matlab.ui.control.Label
        J1Text                      matlab.ui.control.Label
        rPlusButton                 matlab.ui.control.Button
        zPlusButton                 matlab.ui.control.Button
        yPlusButton                 matlab.ui.control.Button
        xPlusButton                 matlab.ui.control.Button
        rMinusButton                matlab.ui.control.Button
        zMinusButton                matlab.ui.control.Button
        yMinusButton                matlab.ui.control.Button
        xMinusButton                matlab.ui.control.Button
        ErrorInfoPanel              matlab.ui.container.Panel
        GetErrorIDButton            matlab.ui.control.Button
        ErrorInfoTextArea           matlab.ui.control.TextArea
        j4PlusButton                matlab.ui.control.Button
        j3PlusButton                matlab.ui.control.Button
        j2PlusButton                matlab.ui.control.Button
        j1PlusButton                matlab.ui.control.Button
        j4MinusButton               matlab.ui.control.Button
        j3MinusButton               matlab.ui.control.Button
        j2MinusButton               matlab.ui.control.Button
        j1MinusButton               matlab.ui.control.Button
        MoveFunctionPanel           matlab.ui.container.Panel
        StopMoveButton              matlab.ui.control.Button
        JointMovJButton             matlab.ui.control.Button
        MovLButton                  matlab.ui.control.Button
        MovJButton                  matlab.ui.control.Button
        J4EditField                 matlab.ui.control.NumericEditField
        J4EditFieldLabel            matlab.ui.control.Label
        J3EditField                 matlab.ui.control.NumericEditField
        J3EditFieldLabel            matlab.ui.control.Label
        J2EditField                 matlab.ui.control.NumericEditField
        J2EditFieldLabel            matlab.ui.control.Label
        J1EditField                 matlab.ui.control.NumericEditField
        J1EditFieldLabel            matlab.ui.control.Label
        REditField                  matlab.ui.control.NumericEditField
        REditFieldLabel             matlab.ui.control.Label
        ZEditField                  matlab.ui.control.NumericEditField
        ZLabel                      matlab.ui.control.Label
        YEditField                  matlab.ui.control.NumericEditField
        YLabel                      matlab.ui.control.Label
        XEditField                  matlab.ui.control.NumericEditField
        XEditFieldLabel             matlab.ui.control.Label
        DashBoardFunctionPanel      matlab.ui.container.Panel
        SpeedConfirmButton          matlab.ui.control.Button
        Label                       matlab.ui.control.Label
        SpeedRatioEditField         matlab.ui.control.EditField
        SpeedRatioLabel             matlab.ui.control.Label
        ClearErrorButton            matlab.ui.control.Button
        ResetRobotButton            matlab.ui.control.Button
        EnableButton                matlab.ui.control.Button
        RobotConnectPanel           matlab.ui.container.Panel
        ConnectButton               matlab.ui.control.StateButton
        FeedBackPortEditFieldLabel  matlab.ui.control.Label
        FeedBackPortEditField       matlab.ui.control.EditField
        MovePortEditFieldLabel      matlab.ui.control.Label
        MovePortEditField           matlab.ui.control.EditField
        DashboarPortEditFieldLabel  matlab.ui.control.Label
        DashboarPortEditField       matlab.ui.control.EditField
        IPAddressEditFieldLabel     matlab.ui.control.Label
        IPAddressEditField          matlab.ui.control.EditField
    end


    properties (Access = private)
        DashboardClient
        MoveClient
        FeedBackClient
        StateDataArray
        StateTimer
        StateWorker
        IsMoveJog
    end

    methods (Access = private)

        function res=TransBytes2Double(app,startIndex)
            bytes=app.StateDataArray(1,startIndex:startIndex+7);
            res=int64(bytes(1,1));
            for i=1:7
                res = bitor(res,bitshift(int64(bytes(1,i+1)),8*i));
            end
            res=typecast(res,"double");
        end
        function FeedBackTcpCallback(app,~, ~)
            if app.FeedBackClient.NumBytesAvailable>0
                app.StateDataArray = read(app.FeedBackClient,app.FeedBackClient.NumBytesAvailable,'uint8');
            end
            robotMode="ROBOT_MODE_NO_CONTROLLER";
            switch app.StateDataArray(1,25)
                case -1
                    robotMode="ROBOT_MODE_NO_CONTROLLER";
                case 0
                    robotMode="ROBOT_MODE_INIT";
                case 1
                    robotMode="ROBOT_MODE_BRAKE_OPEN";
                case 2
                    robotMode="ROBOT_MODE_BOOTING";
                case 3
                    robotMode="ROBOT_MODE_POWER_OFF";
                case 4
                    robotMode="ROBOT_MODE_DISABLED";
                case 5
                    robotMode="ROBOT_MODE_ENABLE";
                case 6
                    robotMode="ROBOT_MODE_BACKDRIVE";
                case 7
                    robotMode="ROBOT_MODE_RUNNING";
                case 8
                    robotMode="ROBOT_MODE_RECORDING";
                case 9
                    robotMode="ROBOT_MODE_ERROR";
                case 10
                    robotMode="ROBOT_MODE_PAUSE";
                case 11
                    robotMode="ROBOT_MODE_JOG";
            end

            app.RobotModeLabel.Text="Robot Mode:"+robotMode;
            app.CurrentSpeedRatioLabel.Text="Current Speed Ratio:"+app.TransBytes2Double(65);

            app.J1Text.Text=""+app.TransBytes2Double(433);
            app.J2Text.Text=""+app.TransBytes2Double(441);
            app.J3Text.Text=""+app.TransBytes2Double(449);
            app.J4Text.Text=""+app.TransBytes2Double(457);
          
            app.xText.Text=""+app.TransBytes2Double(625);
            app.yText.Text=""+app.TransBytes2Double(633);
            app.zText.Text=""+app.TransBytes2Double(641);
            app.rText.Text=""+app.TransBytes2Double(649);
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

        end

        % Value changed function: ConnectButton
        function ConnectButtonValueChanged(app, event)
            text = app.ConnectButton.Text;
            if text=="Connect"
                app.ConnectButton.Text="Disconnect";
                app.DashboardClient=tcpclient(app.IPAddressEditField.Value,str2double(app.DashboarPortEditField.Value));
                app.MoveClient=tcpclient(app.IPAddressEditField.Value,str2double(app.MovePortEditField.Value));
                app.FeedBackClient = tcpclient(app.IPAddressEditField.Value,str2double(app.FeedBackPortEditField.Value));
                configureCallback(app.FeedBackClient,"byte",1440,@app.FeedBackTcpCallback);
            elseif text=="Disconnect"
                app.ConnectButton.Text="Connect";
                configureCallback(app.FeedBackClient,"off")
                clear app.DashboardClient;
                clear app.MoveClient;
                clear app.FeedBackClient;
            end
        end

        % Value changed function: IPAddressEditField
        function IPAddressEditFieldValueChanged(app, event)
            %app.IPAddress = app.IPAddressEditField.Value;

        end

        % Value changed function: DashboarPortEditField
        function DashboarPortEditFieldValueChanged(app, event)
            %app.DashPort = app.DashboarPortEditField.Value;

        end

        % Value changed function: MovePortEditField
        function MovePortEditFieldValueChanged(app, event)
            %app.MovePort = app.MovePortEditField.Value;
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            if  app.ConnectButton.Text=="Disconnect"
                configureCallback(app.FeedBackClient,"off")
                clear app.DashboardClient;
                clear app.MoveClient;
                clear app.FeedBackClient;
            end
            delete(app)

        end

        % Button pushed function: EnableButton
        function EnableButtonPushed(app, event)
            if app.EnableButton.Text=="Enable"
                app.LogTextArea.Value{end+1}=['Send:EnableRobot()'];
                write(app.DashboardClient,"EnableRobot()","char");
                pause(3);
                res=read(app.DashboardClient,app.DashboardClient.NumBytesAvailable);
                app.LogTextArea.Value{end+1}=char(sprintf("Receive:%s",res));
                app.EnableButton.Text="Disable";
            else
                app.LogTextArea.Value{end+1}=['Send:DisableRobot()'];
                write(app.DashboardClient,"DisableRobot()","char");
                pause(1);
                res=read(app.DashboardClient,app.DashboardClient.NumBytesAvailable);
                app.LogTextArea.Value{end+1}=char(sprintf("Receive:%s",res));
                app.EnableButton.Text="Enable";
            end
        end

        % Window button up function: UIFigure
        function UIFigureWindowButtonUp(app, event)
            if app.IsMoveJog
                app.IsMoveJog=false;
                app.LogTextArea.Value{end+1}=['Send:MoveJog()'];
                write(app.MoveClient,"MoveJog()","char");
            end
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            if event.Source.CurrentObject.Tag ~= ""
                app.IsMoveJog=true;
                app.LogTextArea.Value{end+1}=char(sprintf("Send:MoveJog(%s)",event.Source.CurrentObject.Tag));
                write(app.MoveClient,"MoveJog("+event.Source.CurrentObject.Tag+")","char")
            end
        end

        % Button pushed function: ResetRobotButton
        function ResetRobotButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=['Send:ResetRobot()'];
            write(app.DashboardClient,"ResetRobot()","char");
            pause(1);
            res=read(app.DashboardClient,app.DashboardClient.NumBytesAvailable);
            app.LogTextArea.Value{end+1}=char(sprintf("Receive:%s",res));

        end

        % Button pushed function: ClearErrorButton
        function ClearErrorButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=['Send:ClearError()'];
            write(app.DashboardClient,"ClearError()","char");
            pause(1);
            res=read(app.DashboardClient,app.DashboardClient.NumBytesAvailable);
            app.LogTextArea.Value{end+1}=char(sprintf("Receive:%s",res));
        end

        % Button pushed function: SpeedConfirmButton
        function SpeedConfirmButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=char(sprintf("Send:SpeedFactor(%s)",app.SpeedRatioEditField.Value));
            write(app.DashboardClient,"SpeedFactor("+app.SpeedRatioEditField.Value+")","char");
            res=read(app.DashboardClient,app.DashboardClient.NumBytesAvailable);
            pause(1);
            app.LogTextArea.Value{end+1}=char(sprintf("Receive:%s",res));
        end

        % Button pushed function: MovJButton
        function MovJButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=char(sprintf("Send:MovJ(%f,%f,%f,%f,%f,%f)",app.XEditField.Value,app.YEditField.Value,app.ZEditField.Value,app.REditField.Value));
            write(app.MoveClient,"MovJ("+app.XEditField.Value+","+app.YEditField.Value+","+app.ZEditField.Value+","+app.REditField.Value+")","char");
        end

        % Button pushed function: MovLButton
        function MovLButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=char(sprintf("Send:MovL(%f,%f,%f,%f,%f,%f)",app.XEditField.Value,app.YEditField.Value,app.ZEditField.Value,app.REditField.Value));
            write(app.MoveClient,"MovL("+app.XEditField.Value+","+app.YEditField.Value+","+app.ZEditField.Value+","+app.REditField.Value+")","char");
        end

        % Button pushed function: JointMovJButton
        function JointMovJButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=char(sprintf("Send:JointMovJ(%f,%f,%f,%f)",app.J1EditField.Value,app.J2EditField.Value,app.J3EditField.Value,app.J4EditField.Value));
            write(app.MoveClient,"JointMovJ("+app.J1EditField.Value+","+app.J2EditField.Value+","+app.J3EditField.Value+","+app.J4EditField.Value+")","char");
        end

        % Button pushed function: StopMoveButton
        function StopMoveButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=['Send:StopScript()'];
            write(app.MoveClient,"StopScript()","char");
        end

        % Button pushed function: GetErrorIDButton
        function GetErrorIDButtonPushed(app, event)
            app.LogTextArea.Value{end+1}=['Send:GetErrorID()'];
            write(app.DashboardClient,"GetErrorID()","char");
            pause(1);
            res=read(app.DashboardClient,app.DashboardClient.NumBytesAvailable);
            app.ErrorInfoTextArea.Value=char(res);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1166 738];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UIFigure.WindowButtonUpFcn = createCallbackFcn(app, @UIFigureWindowButtonUp, true);

            % Create RobotConnectPanel
            app.RobotConnectPanel = uipanel(app.UIFigure);
            app.RobotConnectPanel.Title = 'Robot Connect';
            app.RobotConnectPanel.Position = [1 656 1168 83];

            % Create IPAddressEditField
            app.IPAddressEditField = uieditfield(app.RobotConnectPanel, 'text');
            app.IPAddressEditField.ValueChangedFcn = createCallbackFcn(app, @IPAddressEditFieldValueChanged, true);
            app.IPAddressEditField.Position = [84 24 136 27];
            app.IPAddressEditField.Value = '192.168.5.1';

            % Create IPAddressEditFieldLabel
            app.IPAddressEditFieldLabel = uilabel(app.RobotConnectPanel);
            app.IPAddressEditFieldLabel.Position = [6 27 63 22];
            app.IPAddressEditFieldLabel.Text = 'IP Address';

            % Create DashboarPortEditField
            app.DashboarPortEditField = uieditfield(app.RobotConnectPanel, 'text');
            app.DashboarPortEditField.ValueChangedFcn = createCallbackFcn(app, @DashboarPortEditFieldValueChanged, true);
            app.DashboarPortEditField.Position = [348 24 136 27];
            app.DashboarPortEditField.Value = '29999';

            % Create DashboarPortEditFieldLabel
            app.DashboarPortEditFieldLabel = uilabel(app.RobotConnectPanel);
            app.DashboarPortEditFieldLabel.Position = [250 27 83 22];
            app.DashboarPortEditFieldLabel.Text = 'Dashboar Port';

            % Create MovePortEditField
            app.MovePortEditField = uieditfield(app.RobotConnectPanel, 'text');
            app.MovePortEditField.ValueChangedFcn = createCallbackFcn(app, @MovePortEditFieldValueChanged, true);
            app.MovePortEditField.Position = [609 24 136 27];
            app.MovePortEditField.Value = '30003';

            % Create MovePortEditFieldLabel
            app.MovePortEditFieldLabel = uilabel(app.RobotConnectPanel);
            app.MovePortEditFieldLabel.Position = [511 27 60 22];
            app.MovePortEditFieldLabel.Text = 'Move Port';

            % Create FeedBackPortEditField
            app.FeedBackPortEditField = uieditfield(app.RobotConnectPanel, 'text');
            app.FeedBackPortEditField.Position = [867 24 136 27];
            app.FeedBackPortEditField.Value = '30004';

            % Create FeedBackPortEditFieldLabel
            app.FeedBackPortEditFieldLabel = uilabel(app.RobotConnectPanel);
            app.FeedBackPortEditFieldLabel.Position = [769 27 85 22];
            app.FeedBackPortEditFieldLabel.Text = 'FeedBack Port';

            % Create ConnectButton
            app.ConnectButton = uibutton(app.RobotConnectPanel, 'state');
            app.ConnectButton.ValueChangedFcn = createCallbackFcn(app, @ConnectButtonValueChanged, true);
            app.ConnectButton.Text = 'Connect';
            app.ConnectButton.Position = [1036 27 100 22];

            % Create DashBoardFunctionPanel
            app.DashBoardFunctionPanel = uipanel(app.UIFigure);
            app.DashBoardFunctionPanel.Title = 'DashBoard Function';
            app.DashBoardFunctionPanel.Position = [2 523 1167 134];

            % Create EnableButton
            app.EnableButton = uibutton(app.DashBoardFunctionPanel, 'push');
            app.EnableButton.ButtonPushedFcn = createCallbackFcn(app, @EnableButtonPushed, true);
            app.EnableButton.BusyAction = 'cancel';
            app.EnableButton.Position = [23 57 100 22];
            app.EnableButton.Text = 'Enable';

            % Create ResetRobotButton
            app.ResetRobotButton = uibutton(app.DashBoardFunctionPanel, 'push');
            app.ResetRobotButton.ButtonPushedFcn = createCallbackFcn(app, @ResetRobotButtonPushed, true);
            app.ResetRobotButton.Position = [142 57 100 22];
            app.ResetRobotButton.Text = 'Reset Robot';

            % Create ClearErrorButton
            app.ClearErrorButton = uibutton(app.DashBoardFunctionPanel, 'push');
            app.ClearErrorButton.ButtonPushedFcn = createCallbackFcn(app, @ClearErrorButtonPushed, true);
            app.ClearErrorButton.Position = [261 57 100 22];
            app.ClearErrorButton.Text = 'Clear Error';

            % Create SpeedRatioLabel
            app.SpeedRatioLabel = uilabel(app.DashBoardFunctionPanel);
            app.SpeedRatioLabel.Position = [380 57 76 22];
            app.SpeedRatioLabel.Text = 'Speed Ratio:';

            % Create SpeedRatioEditField
            app.SpeedRatioEditField = uieditfield(app.DashBoardFunctionPanel, 'text');
            app.SpeedRatioEditField.Position = [466 55 49 27];
            app.SpeedRatioEditField.Value = '50';

            % Create Label
            app.Label = uilabel(app.DashBoardFunctionPanel);
            app.Label.Position = [514 57 25 22];
            app.Label.Text = '%';

            % Create SpeedConfirmButton
            app.SpeedConfirmButton = uibutton(app.DashBoardFunctionPanel, 'push');
            app.SpeedConfirmButton.ButtonPushedFcn = createCallbackFcn(app, @SpeedConfirmButtonPushed, true);
            app.SpeedConfirmButton.Position = [551 57 100 22];
            app.SpeedConfirmButton.Text = 'Confirm';

            % Create MoveFunctionPanel
            app.MoveFunctionPanel = uipanel(app.UIFigure);
            app.MoveFunctionPanel.Title = 'Move Function';
            app.MoveFunctionPanel.Position = [1 375 1168 149];

            % Create XEditFieldLabel
            app.XEditFieldLabel = uilabel(app.MoveFunctionPanel);
            app.XEditFieldLabel.HorizontalAlignment = 'right';
            app.XEditFieldLabel.Position = [25 93 25 22];
            app.XEditFieldLabel.Text = 'X:';

            % Create XEditField
            app.XEditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.XEditField.Limits = [-9999 9999];
            app.XEditField.Position = [65 93 46 22];

            % Create YLabel
            app.YLabel = uilabel(app.MoveFunctionPanel);
            app.YLabel.HorizontalAlignment = 'right';
            app.YLabel.Position = [144 94 25 22];
            app.YLabel.Text = 'Y:';

            % Create YEditField
            app.YEditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.YEditField.Limits = [-9999 9999];
            app.YEditField.Position = [184 94 46 22];

            % Create ZLabel
            app.ZLabel = uilabel(app.MoveFunctionPanel);
            app.ZLabel.HorizontalAlignment = 'right';
            app.ZLabel.Position = [263 93 25 22];
            app.ZLabel.Text = 'Z:';

            % Create ZEditField
            app.ZEditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.ZEditField.Limits = [-9999 9999];
            app.ZEditField.Position = [303 93 46 22];

            % Create REditFieldLabel
            app.REditFieldLabel = uilabel(app.MoveFunctionPanel);
            app.REditFieldLabel.HorizontalAlignment = 'right';
            app.REditFieldLabel.Position = [383 93 25 22];
            app.REditFieldLabel.Text = 'R:';

            % Create REditField
            app.REditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.REditField.Limits = [-9999 9999];
            app.REditField.Position = [423 93 46 22];

            % Create J1EditFieldLabel
            app.J1EditFieldLabel = uilabel(app.MoveFunctionPanel);
            app.J1EditFieldLabel.HorizontalAlignment = 'right';
            app.J1EditFieldLabel.Position = [25 52 25 22];
            app.J1EditFieldLabel.Text = 'J1:';

            % Create J1EditField
            app.J1EditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.J1EditField.Limits = [-9999 9999];
            app.J1EditField.Position = [65 52 46 22];

            % Create J2EditFieldLabel
            app.J2EditFieldLabel = uilabel(app.MoveFunctionPanel);
            app.J2EditFieldLabel.HorizontalAlignment = 'right';
            app.J2EditFieldLabel.Position = [144 53 25 22];
            app.J2EditFieldLabel.Text = 'J2:';

            % Create J2EditField
            app.J2EditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.J2EditField.Limits = [-9999 9999];
            app.J2EditField.Position = [184 53 46 22];

            % Create J3EditFieldLabel
            app.J3EditFieldLabel = uilabel(app.MoveFunctionPanel);
            app.J3EditFieldLabel.HorizontalAlignment = 'right';
            app.J3EditFieldLabel.Position = [263 52 25 22];
            app.J3EditFieldLabel.Text = 'J3:';

            % Create J3EditField
            app.J3EditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.J3EditField.Limits = [-9999 9999];
            app.J3EditField.Position = [303 52 46 22];

            % Create J4EditFieldLabel
            app.J4EditFieldLabel = uilabel(app.MoveFunctionPanel);
            app.J4EditFieldLabel.HorizontalAlignment = 'right';
            app.J4EditFieldLabel.Position = [383 52 25 22];
            app.J4EditFieldLabel.Text = 'J4:';

            % Create J4EditField
            app.J4EditField = uieditfield(app.MoveFunctionPanel, 'numeric');
            app.J4EditField.Limits = [-9999 9999];
            app.J4EditField.Position = [423 52 46 22];

            % Create MovJButton
            app.MovJButton = uibutton(app.MoveFunctionPanel, 'push');
            app.MovJButton.ButtonPushedFcn = createCallbackFcn(app, @MovJButtonPushed, true);
            app.MovJButton.Position = [498 93 100 22];
            app.MovJButton.Text = 'MovJ';

            % Create MovLButton
            app.MovLButton = uibutton(app.MoveFunctionPanel, 'push');
            app.MovLButton.ButtonPushedFcn = createCallbackFcn(app, @MovLButtonPushed, true);
            app.MovLButton.Position = [642 93 100 22];
            app.MovLButton.Text = 'MovL';

            % Create JointMovJButton
            app.JointMovJButton = uibutton(app.MoveFunctionPanel, 'push');
            app.JointMovJButton.ButtonPushedFcn = createCallbackFcn(app, @JointMovJButtonPushed, true);
            app.JointMovJButton.Position = [499 52 100 22];
            app.JointMovJButton.Text = 'JointMovJ';

            % Create StopMoveButton
            app.StopMoveButton = uibutton(app.MoveFunctionPanel, 'push');
            app.StopMoveButton.ButtonPushedFcn = createCallbackFcn(app, @StopMoveButtonPushed, true);
            app.StopMoveButton.Position = [641 52 100 22];
            app.StopMoveButton.Text = 'Stop Move';

            % Create FeedbackPanel
            app.FeedbackPanel = uipanel(app.UIFigure);
            app.FeedbackPanel.Title = 'Feedback';
            app.FeedbackPanel.Position = [2 0 853 376];

            % Create j1MinusButton
            app.j1MinusButton = uibutton(app.FeedbackPanel, 'push');
            app.j1MinusButton.Tag = 'j1-';
            app.j1MinusButton.Position = [10 264 55 22];
            app.j1MinusButton.Text = 'j1-';

            % Create j2MinusButton
            app.j2MinusButton = uibutton(app.FeedbackPanel, 'push');
            app.j2MinusButton.Tag = 'j2-';
            app.j2MinusButton.Position = [10 230 55 22];
            app.j2MinusButton.Text = 'j2-';

            % Create j3MinusButton
            app.j3MinusButton = uibutton(app.FeedbackPanel, 'push');
            app.j3MinusButton.Tag = 'j3-';
            app.j3MinusButton.Position = [10 196 55 22];
            app.j3MinusButton.Text = 'j3-';

            % Create j4MinusButton
            app.j4MinusButton = uibutton(app.FeedbackPanel, 'push');
            app.j4MinusButton.Tag = 'j4-';
            app.j4MinusButton.Position = [10 162 55 22];
            app.j4MinusButton.Text = 'j4-';

            % Create j1PlusButton
            app.j1PlusButton = uibutton(app.FeedbackPanel, 'push');
            app.j1PlusButton.Tag = 'j1+';
            app.j1PlusButton.Position = [165 264 55 22];
            app.j1PlusButton.Text = 'j1+';

            % Create j2PlusButton
            app.j2PlusButton = uibutton(app.FeedbackPanel, 'push');
            app.j2PlusButton.Tag = 'j2+';
            app.j2PlusButton.Position = [167 230 55 22];
            app.j2PlusButton.Text = 'j2+';

            % Create j3PlusButton
            app.j3PlusButton = uibutton(app.FeedbackPanel, 'push');
            app.j3PlusButton.Tag = 'j3+';
            app.j3PlusButton.Position = [167 196 55 22];
            app.j3PlusButton.Text = 'j3+';

            % Create j4PlusButton
            app.j4PlusButton = uibutton(app.FeedbackPanel, 'push');
            app.j4PlusButton.Tag = 'j4+';
            app.j4PlusButton.Position = [167 162 55 22];
            app.j4PlusButton.Text = 'j4+';

            % Create ErrorInfoPanel
            app.ErrorInfoPanel = uipanel(app.FeedbackPanel);
            app.ErrorInfoPanel.Title = 'Error Info';
            app.ErrorInfoPanel.Position = [607 1 245 353];

            % Create ErrorInfoTextArea
            app.ErrorInfoTextArea = uitextarea(app.ErrorInfoPanel);
            app.ErrorInfoTextArea.Editable = 'off';
            app.ErrorInfoTextArea.Position = [0 36 244 297];

            % Create GetErrorIDButton
            app.GetErrorIDButton = uibutton(app.ErrorInfoPanel, 'push');
            app.GetErrorIDButton.ButtonPushedFcn = createCallbackFcn(app, @GetErrorIDButtonPushed, true);
            app.GetErrorIDButton.Position = [136 15 100 22];
            app.GetErrorIDButton.Text = 'GetError ID';

            % Create xMinusButton
            app.xMinusButton = uibutton(app.FeedbackPanel, 'push');
            app.xMinusButton.Tag = 'x-';
            app.xMinusButton.Position = [249 264 55 22];
            app.xMinusButton.Text = 'x-';

            % Create yMinusButton
            app.yMinusButton = uibutton(app.FeedbackPanel, 'push');
            app.yMinusButton.Tag = 'y-';
            app.yMinusButton.Position = [249 230 55 22];
            app.yMinusButton.Text = 'y-';

            % Create zMinusButton
            app.zMinusButton = uibutton(app.FeedbackPanel, 'push');
            app.zMinusButton.Tag = 'z-';
            app.zMinusButton.Position = [249 196 55 22];
            app.zMinusButton.Text = 'z-';

            % Create rMinusButton
            app.rMinusButton = uibutton(app.FeedbackPanel, 'push');
            app.rMinusButton.Tag = 'rx-';
            app.rMinusButton.Position = [249 162 55 22];
            app.rMinusButton.Text = 'r-';

            % Create xPlusButton
            app.xPlusButton = uibutton(app.FeedbackPanel, 'push');
            app.xPlusButton.Tag = 'x+';
            app.xPlusButton.Position = [404 264 55 22];
            app.xPlusButton.Text = 'x+';

            % Create yPlusButton
            app.yPlusButton = uibutton(app.FeedbackPanel, 'push');
            app.yPlusButton.Tag = 'y+';
            app.yPlusButton.Position = [404 230 55 22];
            app.yPlusButton.Text = 'y+';

            % Create zPlusButton
            app.zPlusButton = uibutton(app.FeedbackPanel, 'push');
            app.zPlusButton.Tag = 'z+';
            app.zPlusButton.Position = [404 196 55 22];
            app.zPlusButton.Text = 'z+';

            % Create rPlusButton
            app.rPlusButton = uibutton(app.FeedbackPanel, 'push');
            app.rPlusButton.Tag = 'rx+';
            app.rPlusButton.Position = [404 162 55 22];
            app.rPlusButton.Text = 'r+';

            % Create J1Text
            app.J1Text = uilabel(app.FeedbackPanel);
            app.J1Text.HorizontalAlignment = 'center';
            app.J1Text.Position = [67 264 99 22];
            app.J1Text.Text = '0.0';

            % Create J2Text
            app.J2Text = uilabel(app.FeedbackPanel);
            app.J2Text.HorizontalAlignment = 'center';
            app.J2Text.Position = [67 230 99 22];
            app.J2Text.Text = '0.0';

            % Create J3Text
            app.J3Text = uilabel(app.FeedbackPanel);
            app.J3Text.HorizontalAlignment = 'center';
            app.J3Text.Position = [67 196 99 22];
            app.J3Text.Text = '0.0';

            % Create J4Text
            app.J4Text = uilabel(app.FeedbackPanel);
            app.J4Text.HorizontalAlignment = 'center';
            app.J4Text.Position = [67 162 99 22];
            app.J4Text.Text = '0.0';

            % Create xText
            app.xText = uilabel(app.FeedbackPanel);
            app.xText.HorizontalAlignment = 'center';
            app.xText.Position = [307 264 98 22];
            app.xText.Text = '0.0';

            % Create yText
            app.yText = uilabel(app.FeedbackPanel);
            app.yText.HorizontalAlignment = 'center';
            app.yText.Position = [306 230 99 22];
            app.yText.Text = '0.0';

            % Create zText
            app.zText = uilabel(app.FeedbackPanel);
            app.zText.HorizontalAlignment = 'center';
            app.zText.Position = [307 196 98 22];
            app.zText.Text = '0.0';

            % Create rText
            app.rText = uilabel(app.FeedbackPanel);
            app.rText.HorizontalAlignment = 'center';
            app.rText.Position = [307 162 98 22];
            app.rText.Text = '0.0';

            % Create RobotModeLabel
            app.RobotModeLabel = uilabel(app.FeedbackPanel);
            app.RobotModeLabel.Position = [12 294 251 22];
            app.RobotModeLabel.Text = 'Robot Mode:';

            % Create CurrentSpeedRatioLabel
            app.CurrentSpeedRatioLabel = uilabel(app.FeedbackPanel);
            app.CurrentSpeedRatioLabel.Position = [12 323 251 22];
            app.CurrentSpeedRatioLabel.Text = 'Current Speed Ratio:';

            % Create LogPanel
            app.LogPanel = uipanel(app.UIFigure);
            app.LogPanel.Title = 'Log';
            app.LogPanel.Position = [854 1 315 375];

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.LogPanel);
            app.LogTextArea.Editable = 'off';
            app.LogTextArea.Position = [0 0 313 354];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CRMATLABDemo_mg400

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end