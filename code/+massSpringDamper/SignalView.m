classdef SignalView < massSpringDamper.MassSpringDamperComponent
    %SIGNALVIEW Displays the simulation signals.

    % Copyright 2025-2026 The MathWorks, Inc

    properties ( Access = private )
        % Time scopes for plotting the simulation signals.
        SignalTimeScope(:, 1) matlab.ui.scope.TimeScope
    end % properties ( Access = private )

    methods

        function obj = SignalView( model, namedArgs )
            %SIGNALVIEW Construct a SignalView object, given
            %the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.SignalView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@massSpringDamper.MassSpringDamperComponent( model )            

            % Bind each timescope with the corresponding signal.            
            for signalIdx = 1 : obj.Model.NumSignals
                set( obj.SignalTimeScope(signalIdx), ...
                    "LegendNames", obj.Model.SignalNames(signalIdx), ...
                    "YLabel", obj.Model.SignalNames(signalIdx) + ...
                    " (" + obj.Model.SignalUnits(signalIdx) + ")", ...
                    "Title", obj.Model.SignalNames(signalIdx) )
                obj.Bindings(signalIdx, 1) = bind( ...
                    obj.Model.Simulation.LoggedSignals, ...
                    obj.Model.LoggedSignalPath(signalIdx), ...
                    obj.SignalTimeScope(signalIdx) );
            end % for

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component.

            % Define the timescope layout.
            numSignals = massSpringDamper.Model.NumSignals;
            mainGrid = uigridlayout( obj, [numSignals, 1] );

            % Add the time scopes and bind them to the signals.
            for signalIdx = 1 : numSignals
                obj.SignalTimeScope(signalIdx) = uitimescope( ...
                    "Parent", mainGrid, ...
                    "XTimeSpan", 100, ...
                    "XLabel", "Time" );
                if signalIdx == 1
                    obj.SignalTimeScope(signalIdx).PlotType = "stairs";
                end % if
            end % for

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

    end % methods ( Access = protected )

end % classdef