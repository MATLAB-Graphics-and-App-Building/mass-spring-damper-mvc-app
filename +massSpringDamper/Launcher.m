classdef Launcher < handle
    %LAUNCHER Launcher for the Mass Spring Damper application.

    % Main app figure.
    properties ( SetAccess = private )
        % Main app figure.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}
    end % properties ( SetAccess = private )

    % Model-related properties.
    properties ( Access = private )
        % Model.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( Access = private )


    methods

        function obj = Launcher()
            %LAUNCHER Constructor, launching the app.

            % Create the app's figure.
            obj.Figure = uifigure( "Name", "Mass Spring Damper",...
                "Visible", "off",...
                "Units", "normalized", ...
                "AutoResizeChildren", "off", ...
                "WindowState", "maximized");
            %"CloseRequestFcn", @obj.onClose );

            % Create the model.
            modelName= "MassSpringDamperModel";
            obj.Model = massSpringDamper.Model(modelName);

            % Create the home layout and add components.
            homeLayout = uigridlayout(obj.Figure,...
                "ColumnWidth", {"1x", "2.5x"},...
                "RowHeight", {"1x", "2x"});

            modelImage = massSpringDamper.ModelImageView(obj.Model,...
                "Parent", homeLayout);
            modelImage.Layout.Row = 1;
            modelImage.Layout.Column = 1;

            simulationController = massSpringDamper.SimulationController(obj.Model,...
                "Parent", homeLayout);
            simulationController.Layout.Row = 2;
            simulationController.Layout.Column = 1;


            signalView = massSpringDamper.SignalView(obj.Model,...
                "Parent", homeLayout);
            signalView.Layout.Row = [1, 2];
            signalView.Layout.Column = 2;

            % Make the main figure visible.
            obj.Figure.Visible = "on";

        end % function obj = Launcher()
    end % methods

end % class