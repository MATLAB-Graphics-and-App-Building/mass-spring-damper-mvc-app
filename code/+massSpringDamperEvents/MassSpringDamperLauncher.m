classdef MassSpringDamperLauncher < handle
    %LAUNCHER Launcher for the Mass Spring Damper application.

    % Copyright 2025-2026 The MathWorks, Inc

    properties ( SetAccess = private )
        % Main app figure.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}
    end % properties ( SetAccess = private )

    properties ( Access = private )
        % Application data model.
        Model(:, 1) massSpringDamperEvents.Model {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = MassSpringDamperLauncher( f )
            %MASSSPRINGDAMPERLAUNCHER Constructor, launching the app.

            arguments ( Input )
                f(1, 1) matlab.ui.Figure = uifigure()
            end % arguments ( Input )

            % Create the app's figure.
            obj.Figure = f;
            set( obj.Figure, "Name", "Mass Spring Damper App", ...
                "Units", "normalized", ...
                "Position", [0.1, 0.1, 0.8, 0.8], ...
                "CloseRequestFcn", @obj.onFigureClosed, ...
                "Visible", "off" )

            % Initialize the model.
            obj.Model = massSpringDamperEvents.Model();

            % Define the main layout.
            mainLayout = uigridlayout( obj.Figure,...
                "ColumnWidth", ["2.5x", "1x"],...
                "RowHeight", ["1x", "1x"] );

            % Add the views and controllers.
            SV = massSpringDamperEvents.SignalView( obj.Model, ...
                "Parent", mainLayout );
            SV.Layout.Row = [1, 2];
            SV.Layout.Column = 1;

            MIV = massSpringDamperEvents.ModelImageView( obj.Model, ...
                "Parent", mainLayout );
            MIV.Layout.Row = 1;
            MIV.Layout.Column = 2;

            SC = massSpringDamperEvents.SimulationController( ...
                obj.Model, "Parent", mainLayout );
            SC.Layout.Row = 2;
            SC.Layout.Column = 2;

            % Show the figure.
            obj.Figure.Visible = "on";

        end % constructor

        function delete( obj )
            %DELETE Delete the figure.

            delete( obj.Figure )

        end % destructor

    end % methods

    methods ( Access = private )

        function onFigureClosed( obj, ~, ~ )
            %ONFIGURECLOSED Delete the launcher.

            delete( obj )

        end % onFigureClosed

    end % methods ( Access = private )

end % classdef