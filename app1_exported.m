classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        DRIVEImagesButton       matlab.ui.control.Button
        GroundTruthLabel        matlab.ui.control.Label
        ResultImageLabel        matlab.ui.control.Label
        UIAxes                  matlab.ui.control.UIAxes
        OriginalImageLabel      matlab.ui.control.Label
        DRIVEManualButton       matlab.ui.control.Button
        UIAxes_2                matlab.ui.control.UIAxes
        UIAxes_3                matlab.ui.control.UIAxes
        GABORFILTERButtonGroup  matlab.ui.container.ButtonGroup
        Button                  matlab.ui.control.RadioButton
        Button_2                matlab.ui.control.RadioButton
        Button_3                matlab.ui.control.RadioButton
        Button_4                matlab.ui.control.RadioButton
        Button_5                matlab.ui.control.RadioButton
        Button_6                matlab.ui.control.RadioButton
        AccuracyEditFieldLabel  matlab.ui.control.Label
        AccuracyEditField       matlab.ui.control.NumericEditField
        PSNREditFieldLabel      matlab.ui.control.Label
        PSNREditField           matlab.ui.control.NumericEditField
        ClearAllButton          matlab.ui.control.Button
        CHASEImagesButton       matlab.ui.control.Button
        HRFImagesButton         matlab.ui.control.Button
        CHASEManualButton       matlab.ui.control.Button
        HRFManualButton         matlab.ui.control.Button
        SegmentationButton      matlab.ui.control.Button
    end

    
    properties (Access = private)
        image;
        image2; % Description
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: DRIVEImagesButton
        function DRIVEImagesButtonPushed(app, event)
            [FileName, FilePath]= uigetfile('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\DRIVE\training\images\*.tif'); %Don't override path.m
            figure(app.UIFigure);
            if isnumeric(FileName) 
                return; 
            end %User did not select a file
            app.image = imread(fullfile(FilePath, FileName)); %Always use full file path, not relative path
            imshow(app.image, 'Parent' , app.UIAxes);
        end

        % Button pushed function: DRIVEManualButton
        function DRIVEManualButtonPushed(app, event)
            [FileName, FilePath]= uigetfile('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\DRIVE\training\1st_manual\*.gif'); %Don't override path.m
            figure(app.UIFigure);
            if isnumeric(FileName) 
                return; 
            end %User did not select a file
            app.image2 = imread(fullfile(FilePath, FileName)); %Always use full file path, not relative path
            imshow(app.image2, 'Parent' , app.UIAxes_2);
        end

        % Button pushed function: ClearAllButton
        function ClearAllButtonPushed(app, event)
            cla(app.UIAxes);
            cla(app.UIAxes_2);
            cla(app.UIAxes_3);
            app.AccuracyEditField.Value = 0;
            app.PSNREditField.Value = 0;
        end

        % Button pushed function: CHASEImagesButton
        function CHASEImagesButtonPushed(app, event)
            [FileName, FilePath]= uigetfile('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\CHASEDB1\Images\*.jpg'); %Don't override path.m
            figure(app.UIFigure);
            if isnumeric(FileName) 
                return; 
            end %User did not select a file
            app.image = imread(fullfile(FilePath, FileName)); %Always use full file path, not relative path
            imshow(app.image, 'Parent' , app.UIAxes);
        end

        % Button pushed function: CHASEManualButton
        function CHASEManualButtonPushed(app, event)
            [FileName, FilePath]= uigetfile('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\CHASEDB1\1st_manual\*.png'); %Don't override path.m
            figure(app.UIFigure);
            if isnumeric(FileName) 
                return; 
            end %User did not select a file
            app.image2 = imread(fullfile(FilePath, FileName)); %Always use full file path, not relative path
            imshow(app.image2, 'Parent' , app.UIAxes_2);
        end

        % Button pushed function: HRFImagesButton
        function HRFImagesButtonPushed(app, event)
            [FileName, FilePath]= uigetfile('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\HRF\images\*.jpg'); %Don't override path.m
            figure(app.UIFigure);
            if isnumeric(FileName) 
                return; 
            end %User did not select a file
            app.image = imread(fullfile(FilePath, FileName)); %Always use full file path, not relative path
            imshow(app.image, 'Parent' , app.UIAxes);
        end

        % Button pushed function: HRFManualButton
        function HRFManualButtonPushed(app, event)
          [FileName, FilePath]= uigetfile('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\HRF\manual1\*.tif'); %Don't override path.m
            figure(app.UIFigure);
            if isnumeric(FileName) 
                return; 
            end %User did not select a file
            app.image2 = imread(fullfile(FilePath, FileName)); %Always use full file path, not relative path
            imshow(app.image2, 'Parent' , app.UIAxes_2);  
        end

        % Callback function: AccuracyEditField, 
        % GABORFILTERButtonGroup, PSNREditField, SegmentationButton
        function SegmentationButtonPushed(app, event)
            R = imresize(app.image, [900 1000]);
            R = im2double(R);
            
            G = R(:,:,2);
            C = adapthisteq(G);
            se = strel('disk', 3);
            O = imopen(C, se);
            
            gamma = 0.65;  %aspect ratio 
            psi = 0; %phase
            
            if app.Button.Value
                theta = 15;
            elseif app.Button_2.Value
                theta = 37;
            elseif app.Button_3.Value
                theta = 59;
            elseif app.Button_4.Value
                theta = 81;
            elseif app.Button_5.Value
                theta = 103;
            elseif app.Button_6.Value
                theta = 125;
            end
            
            bw = 0.15; %bandwidth or effective width 
            lambda = 10; %wave1ength 
            pi = 180;
            
            for x = 1:900
                for y = 1:1000
        
                    x_theta = O(x,y)*cos(theta)+O(x,y)*sin(theta); 
                    y_theta = -O(x,y).*sin(theta)+O(x,y).*cos(theta);
        
                    sigma = (1/pi*(sqrt(log(2)/2))*((2.^bw+1)/(2.^bw-1)))*lambda;

                    gb(x,y) = exp(-0.5*((x_theta.^2/sigma)+((gamma.^2*y_theta.^2)/sigma)))*cos(2*pi*((x_theta/lambda)+psi));
                end
            end
            
            se = strel('disk', 8);
            tP = imtophat(gb, se);
            
            V = imread('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\DRIVE\training\mask\21_training_mask.gif');
            VR = imresize(V, [900 1000]);
            VR = im2double(VR);
            
            T = graythresh(tP);
            [T,EM] = graythresh(tP);
            BW = imbinarize(tP, T);
            BW2 = im2double(BW);
            BW = BW2.*VR;
            
            imshow(BW, 'Parent' , app.UIAxes_3);
            
            R = imresize(app.image2, [900 1000]);
            R2 = im2double(R);
            sumindex = R2 + BW;
            TP = length(find(sumindex == 2));
            TN = length(find(sumindex == 0));
            substractindex = R2 - BW;
            FP = length(find(substractindex == -1));
            FN = length(find(substractindex == 1));
            
            acc = (TP+TN)/(FN+FP+TP+TN);
            peaksnr = psnr(R2, BW);
            
            app.AccuracyEditField.Value = acc;
            app.PSNREditField.Value = peaksnr;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9294 0.6941 0.1255];
            app.UIFigure.Position = [100 100 921 557];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Pointer = 'hand';

            % Create DRIVEImagesButton
            app.DRIVEImagesButton = uibutton(app.UIFigure, 'push');
            app.DRIVEImagesButton.ButtonPushedFcn = createCallbackFcn(app, @DRIVEImagesButtonPushed, true);
            app.DRIVEImagesButton.Position = [51 136 170 22];
            app.DRIVEImagesButton.Text = 'DRIVE Images';

            % Create GroundTruthLabel
            app.GroundTruthLabel = uilabel(app.UIFigure);
            app.GroundTruthLabel.FontName = 'Comic Sans MS';
            app.GroundTruthLabel.FontSize = 20;
            app.GroundTruthLabel.Position = [320 507 132 31];
            app.GroundTruthLabel.Text = 'Ground Truth';

            % Create ResultImageLabel
            app.ResultImageLabel = uilabel(app.UIFigure);
            app.ResultImageLabel.FontName = 'Comic Sans MS';
            app.ResultImageLabel.FontSize = 20;
            app.ResultImageLabel.Position = [573 507 128 31];
            app.ResultImageLabel.Text = 'Result Image';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [1.26162790697674 1 1];
            app.UIAxes.GridColor = 'none';
            app.UIAxes.MinorGridColor = 'none';
            app.UIAxes.XColor = 'none';
            app.UIAxes.YColor = 'none';
            app.UIAxes.Color = 'none';
            app.UIAxes.Position = [21 168 230 330];

            % Create OriginalImageLabel
            app.OriginalImageLabel = uilabel(app.UIFigure);
            app.OriginalImageLabel.FontName = 'Comic Sans MS';
            app.OriginalImageLabel.FontSize = 20;
            app.OriginalImageLabel.Position = [66 507 140 31];
            app.OriginalImageLabel.Text = 'Original Image';

            % Create DRIVEManualButton
            app.DRIVEManualButton = uibutton(app.UIFigure, 'push');
            app.DRIVEManualButton.ButtonPushedFcn = createCallbackFcn(app, @DRIVEManualButtonPushed, true);
            app.DRIVEManualButton.Position = [301 136 170 22];
            app.DRIVEManualButton.Text = 'DRIVE Manual';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, '')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            app.UIAxes_2.PlotBoxAspectRatio = [1.26162790697674 1 1];
            app.UIAxes_2.GridColor = 'none';
            app.UIAxes_2.MinorGridColor = 'none';
            app.UIAxes_2.XColor = 'none';
            app.UIAxes_2.YColor = 'none';
            app.UIAxes_2.Color = 'none';
            app.UIAxes_2.Position = [271 168 229 330];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, '')
            xlabel(app.UIAxes_3, 'X')
            ylabel(app.UIAxes_3, 'Y')
            app.UIAxes_3.PlotBoxAspectRatio = [1.26162790697674 1 1];
            app.UIAxes_3.GridColor = 'none';
            app.UIAxes_3.MinorGridColor = 'none';
            app.UIAxes_3.XColor = 'none';
            app.UIAxes_3.YColor = 'none';
            app.UIAxes_3.Color = 'none';
            app.UIAxes_3.Position = [522 168 229 330];

            % Create GABORFILTERButtonGroup
            app.GABORFILTERButtonGroup = uibuttongroup(app.UIFigure);
            app.GABORFILTERButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SegmentationButtonPushed, true);
            app.GABORFILTERButtonGroup.ForegroundColor = [1 1 1];
            app.GABORFILTERButtonGroup.TitlePosition = 'centertop';
            app.GABORFILTERButtonGroup.Title = 'GABOR FILTER';
            app.GABORFILTERButtonGroup.BackgroundColor = [1 0.4118 0.1608];
            app.GABORFILTERButtonGroup.FontSize = 15;
            app.GABORFILTERButtonGroup.Position = [765 107 141 365];

            % Create Button
            app.Button = uiradiobutton(app.GABORFILTERButtonGroup);
            app.Button.Text = '15';
            app.Button.FontColor = [1 1 1];
            app.Button.Position = [10 312 58 22];
            app.Button.Value = true;

            % Create Button_2
            app.Button_2 = uiradiobutton(app.GABORFILTERButtonGroup);
            app.Button_2.Text = '37';
            app.Button_2.FontColor = [1 1 1];
            app.Button_2.Position = [10 252 65 22];

            % Create Button_3
            app.Button_3 = uiradiobutton(app.GABORFILTERButtonGroup);
            app.Button_3.Text = '59';
            app.Button_3.FontColor = [1 1 1];
            app.Button_3.Position = [10 192 65 22];

            % Create Button_4
            app.Button_4 = uiradiobutton(app.GABORFILTERButtonGroup);
            app.Button_4.Text = '81';
            app.Button_4.FontColor = [1 1 1];
            app.Button_4.Position = [11 128 65 22];

            % Create Button_5
            app.Button_5 = uiradiobutton(app.GABORFILTERButtonGroup);
            app.Button_5.Text = '103';
            app.Button_5.FontColor = [1 1 1];
            app.Button_5.Position = [11 69 65 22];

            % Create Button_6
            app.Button_6 = uiradiobutton(app.GABORFILTERButtonGroup);
            app.Button_6.Text = '125';
            app.Button_6.FontColor = [1 1 1];
            app.Button_6.Position = [10 11 65 22];

            % Create AccuracyEditFieldLabel
            app.AccuracyEditFieldLabel = uilabel(app.UIFigure);
            app.AccuracyEditFieldLabel.HorizontalAlignment = 'right';
            app.AccuracyEditFieldLabel.Position = [547 86 55 22];
            app.AccuracyEditFieldLabel.Text = 'Accuracy';

            % Create AccuracyEditField
            app.AccuracyEditField = uieditfield(app.UIFigure, 'numeric');
            app.AccuracyEditField.ValueChangedFcn = createCallbackFcn(app, @SegmentationButtonPushed, true);
            app.AccuracyEditField.Position = [617 86 110 22];

            % Create PSNREditFieldLabel
            app.PSNREditFieldLabel = uilabel(app.UIFigure);
            app.PSNREditFieldLabel.HorizontalAlignment = 'right';
            app.PSNREditFieldLabel.Position = [557 36 39 22];
            app.PSNREditFieldLabel.Text = 'PSNR';

            % Create PSNREditField
            app.PSNREditField = uieditfield(app.UIFigure, 'numeric');
            app.PSNREditField.ValueChangedFcn = createCallbackFcn(app, @SegmentationButtonPushed, true);
            app.PSNREditField.Position = [617 36 110 22];

            % Create ClearAllButton
            app.ClearAllButton = uibutton(app.UIFigure, 'push');
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAllButtonPushed, true);
            app.ClearAllButton.Position = [765 65 123 22];
            app.ClearAllButton.Text = 'Clear All';

            % Create CHASEImagesButton
            app.CHASEImagesButton = uibutton(app.UIFigure, 'push');
            app.CHASEImagesButton.ButtonPushedFcn = createCallbackFcn(app, @CHASEImagesButtonPushed, true);
            app.CHASEImagesButton.Position = [51 86 170 22];
            app.CHASEImagesButton.Text = {'CHASE Images'; ''};

            % Create HRFImagesButton
            app.HRFImagesButton = uibutton(app.UIFigure, 'push');
            app.HRFImagesButton.ButtonPushedFcn = createCallbackFcn(app, @HRFImagesButtonPushed, true);
            app.HRFImagesButton.Position = [51 36 170 22];
            app.HRFImagesButton.Text = 'HRF Images';

            % Create CHASEManualButton
            app.CHASEManualButton = uibutton(app.UIFigure, 'push');
            app.CHASEManualButton.ButtonPushedFcn = createCallbackFcn(app, @CHASEManualButtonPushed, true);
            app.CHASEManualButton.Position = [301 86 170 22];
            app.CHASEManualButton.Text = 'CHASE Manual';

            % Create HRFManualButton
            app.HRFManualButton = uibutton(app.UIFigure, 'push');
            app.HRFManualButton.ButtonPushedFcn = createCallbackFcn(app, @HRFManualButtonPushed, true);
            app.HRFManualButton.Position = [301 36 170 22];
            app.HRFManualButton.Text = 'HRF Manual';

            % Create SegmentationButton
            app.SegmentationButton = uibutton(app.UIFigure, 'push');
            app.SegmentationButton.ButtonPushedFcn = createCallbackFcn(app, @SegmentationButtonPushed, true);
            app.SegmentationButton.Position = [552 136 170 22];
            app.SegmentationButton.Text = 'Segmentation';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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