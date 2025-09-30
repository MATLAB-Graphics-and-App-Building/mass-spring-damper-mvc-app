classdef SignalView < massSpringDamper.Component
    %SIGNALVIEW Displays the simulation signals for the External Force,
    %Acceleration, Velocity and Position.

    properties ( Access = private )
        % TimeScope for External Force.
        ExternalForceTS(1, 1) matlab.ui.scope.TimeScope {mustBeScalarOrEmpty}
        % TimeScope for Acceleration.
        AccelerationTS(1, 1) matlab.ui.scope.TimeScope {mustBeScalarOrEmpty}
        % TimeScope for Velocity.
        VelocityTS(1, 1) matlab.ui.scope.TimeScope {mustBeScalarOrEmpty}
        % TimeScope for Position.
        PositionTS(1, 1) matlab.ui.scope.TimeScope {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )

    methods

        function obj = SignalView( model, namedArgs )
            %SIGNALVIEW Construct a SignalView object, given
            %the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.SignalView
            end % arguments ( Input )

            % Assign the model.
            obj.Model = model;

            % Set any user-specified properties.
            set( obj, namedArgs )

            % Bind the model signals with the timescopes.
            bind(obj.Model.Signals, obj.Model.ExternalForceLinePath, obj.ExternalForceTS);
            bind(obj.Model.Signals, obj.Model.AccLinePath, obj.AccelerationTS);
            bind(obj.Model.Signals, obj.Model.VelLinePath, obj.VelocityTS);
            bind(obj.Model.Signals, obj.Model.PosLinePath, obj.PositionTS);

        end % constructor

    end % methods

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
            obj.AccelerationTS.Layout.Row = 2;
            obj.AccelerationTS.Layout.Column = 1;

            obj.VelocityTS = uitimescope(...
                "Parent", mainLayout,...
                "XTimeSpan", 1,...
                "YLimits", [0, 1],...
                "Title", "Velocity");
            obj.VelocityTS.Layout.Row = 3;
            obj.VelocityTS.Layout.Column = 1;

            obj.PositionTS = uitimescope(...
                "Parent", mainLayout,...
                "XTimeSpan", 1,...
                "YLimits", [0, 1],...
                "Title", "Position");
            obj.PositionTS.Layout.Row = 4;
            obj.PositionTS.Layout.Column = 1;

        end % setup

        function update( ~ )
            % Complete code
        end % update

    end % methods ( Access = protected )

end % classdef