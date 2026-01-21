classdef MassSpringDamperLauncher < handle
    %LAUNCHER Launcher for the Mass Spring Damper application.

    % Copyright 2025-2026 The MathWorks, Inc

    properties ( SetAccess = private )
        % Main app figure.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}
    end % properties ( SetAccess = private )

    properties ( Access = private )
        % Application data model.
        Model(:, 1) Model {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = MassSpringDamperLauncher()
            %MASSSPRINGDAMPERLAUNCHER Constructor, launching the app.

            % Create the app's figure.
            obj.Figure = uifigure( ...
                "Name", "Mass Spring Damper App", ...
                "Visible", "off" );

            % Initialize the model.
            obj.Model = Model();

            % Define the main layout.
            mainLayout = uigridlayout( obj.Figure,...
                "ColumnWidth", ["2.5x", "1x"],...
                "RowHeight", ["1x", "1x"] );

            % Add the views and controllers.
            SV = SignalView( obj.Model, "Parent", mainLayout );
            SV.Layout.Row = [1, 2];
            SV.Layout.Column = 1;
            
            MIV = ModelImageView( obj.Model, "Parent", mainLayout );
            MIV.Layout.Row = 1;
            MIV.Layout.Column = 2;

            SC = SimulationController( obj.Model, "Parent", mainLayout );
            SC.Layout.Row = 2;
            SC.Layout.Column = 2;
            
            % Show the figure.
            obj.Figure.Visible = "on";

        end % constructor

    end % methods

end % classdef