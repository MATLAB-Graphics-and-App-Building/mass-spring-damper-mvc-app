classdef SignalView < MassSpringDamperComponent
    %SIGNALVIEW Displays the simulation signals for the External Force,
    %Acceleration, Velocity and Position.

    properties ( Access = private )
        % Line plots to display the output signals.
        Lines(:, 1) matlab.graphics.primitive.Line
    end % properties ( Access = private )

    methods

        function obj = SignalView( model, namedArgs )
            %SIGNALVIEW Construct a SignalView object, given
            %the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) Model
                namedArgs.?SignalView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@MassSpringDamperComponent( model )

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function onStatusChanged( ~, ~, ~ )
            %ONSTATUSCHANGED Respond to the model event "StatusChanged".

        end % onStatusChanged

        function onSimulationStepped( obj, ~, ~ )
            %ONSIMULATIONSTEPPED Respond to the model event
            %"SimulationStepped".

            tt = obj.Model.OutputLog;
            time = tt.Properties.RowTimes;
            set( obj.Lines(1), "XData", time, "YData", tt.Force )
            set( obj.Lines(2), "XData", time, "YData", tt.Position )
            set( obj.Lines(3), "XData", time, "YData", tt.Velocity )
            set( obj.Lines(4), "XData", time, "YData", tt.Acceleration )

        end % onSimulationStepped

        function setup( obj )
            %SETUP Initialize the component.

            % Initialize the tiled layout, axes, and lines.
            tl = tiledlayout( 4, 1, "Parent", obj );
            ax = gobjects( 4, 1 );
            varNames = Model.SignalNames;
            varUnits = Model.SignalUnits;

            for k = 1 : 4
                ax(k) = nexttile( tl );                
                obj.Lines(k) = line( ax(k), seconds( NaN ), NaN, ...
                    "Marker", ".", ...
                    "Color", ax(k).ColorOrder(k, :), ...
                    "LineWidth", 1.5 );                
                ylabel( ax(k), varNames(k) + " (" + varUnits(k) + ")" )
                grid( ax(k), "on" )
            end % for

            xlabel( tl, "Time (s)" )
            title( tl, "Signals" )

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

    end % methods ( Access = protected )

end % classdef