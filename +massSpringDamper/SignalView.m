classdef SignalView < matlab.ui.componentcontainer.ComponentContainer
    %SIGNALVIEW Displays the simulation signals for the External Force,
    %Acceleration, Velocity and Position.

    properties ( Access = private )
        % TimeScope for External Force.
        ExternalForceTS(1, 1) matlab.ui.scope.TimeScope
        % TimeScope for Acceleration.
        AccelerationTS(1, 1) matlab.ui.scope.TimeScope
        % TimeScope for Velocity.
        VelocityTS(1, 1) matlab.ui.scope.TimeScope
        % TimeScope for Position.
        PositionTS(1, 1) matlab.ui.scope.TimeScope
    end % properties ( Access = private )

    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )


    methods ( Access = protected )

        function setup ( obj )
            %SETUP Initialize the component.

            % Create the main layout.
            mainLayout = uigridlayout(obj, [4, 1],...
                "Padding", 0);

            % Create the time scopes.
            obj.ExternalForceTS = uitimescope(...
                "Parent", mainLayout,...
                "XTimeSpan", 1,...
                "YLimits", [0, 1],...
                "Title", "External Force");
            obj.ExternalForceTS.Layout.Row = 1;
            obj.ExternalForceTS.Layout.Column = 1;

            obj.AccelerationTS = uitimescope(...
                "Parent", mainLayout,...
                "XTimeSpan", 1,...
                "YLimits", [0, 1],...
                "Title", "Acceleration");
            obj.ExternalForceTS.Layout.Row = 2;
            obj.ExternalForceTS.Layout.Column = 1;

            obj.VelocityTS = uitimescope(...
                "Parent", mainLayout,...
                "XTimeSpan", 1,...
                "YLimits", [0, 1],...
                "Title", "Velocity");
            obj.ExternalForceTS.Layout.Row = 3;
            obj.ExternalForceTS.Layout.Column = 1;

            obj.PositionTS = uitimescope(...
                "Parent", mainLayout,...
                "XTimeSpan", 1,...
                "YLimits", [0, 1],...
                "Title", "Position");
            obj.ExternalForceTS.Layout.Row = 4;
            obj.ExternalForceTS.Layout.Column = 1;

        end % setup

        function update( obj )
            
        end % update

    end % methods ( Access = protected )

end % classdef