classdef Model < handle
    %MODEL Data model for the mass-spring-damper app.

    % Copyright 2025-2026 The MathWorks, Inc

    properties
        % Spring stiffness - k (N/m).
        Stiffness(1, 1) double {mustBePositive, mustBeFinite} = 100
        % Mass - m (kg).
        Mass(1, 1) double {mustBePositive, mustBeFinite} = 10
        % Damping coefficient - b (N/m/s).
        DampingCoefficient(1, 1) double {mustBePositive, mustBeFinite} = 1
        % Initial position/displacement - x0 (m).
        InitialPosition(1, 1) double ...
            {mustBeNonnegative, mustBeFinite} = 0.5
        % Input change interval - dt (s).
        InputChangeInterval(1, 1) double ...
            {mustBeNonnegative, mustBeFinite} = 10
    end % properties

    properties ( Constant )
        % Simulink model name.
        SimulinkModelName(1, 1) string = "MassSpringDamperModel"
        % Model image file.
        ImageFile(1, 1) string {mustBeFile} = "models/" + ...
            massSpringDamperEvents.Model.SimulinkModelName + ".svg"
        % Signal names.
        SignalNames(1, 4) string = ["Force", "Position", ...
            "Velocity", "Acceleration"]
        % Number of signals.
        NumSignals(1, 1) double {mustBeInteger, mustBePositive} = ...
            numel( massSpringDamper.Model.SignalNames )
        % Signal paths.
        LoggedSignalPath(1, 4) string = ...
            massSpringDamper.Model.SimulinkModelName + ...
            ["/External Force:1", "/Second-Order Integrator:1", ...
            "/Second-Order Integrator:2", "/Mass:1"]
        % Signal units.
        SignalUnits(1, 4) string = ["N", "m", "m/s", "m/s^2"]
        % Constant block path.
        ExternalForceBlockPath(1, 1) string = ...
            massSpringDamper.Model.SimulinkModelName + "/External Force"
        % Block paths.
        BlockPaths(1, 4) string = ...
            massSpringDamper.Model.SimulinkModelName + "/" + ...
            ["Stiffness", "Mass", "Damping", "Initial Position"]
    end % properties ( Constant )

    properties ( SetAccess = private )
        % Simulation object, of type simulink.Simulation.
        Simulation(:, 1) simulink.Simulation {mustBeScalarOrEmpty} = ...
            simulink.Simulation.empty( 0, 1 )
    end % properties ( SetAccess = private )

    methods

        function obj = Model( namedArgs )
            %MODEL Construct the model.

            arguments ( Input )
                namedArgs.?massSpringDamper.Model
            end % arguments ( Input )

            % Load the model and create the Simulation object.
            load_system( obj.SimulinkModelName )
            obj.Simulation = simulink.Simulation( ...
                obj.SimulinkModelName );

            % Assign any user-specified properties.
            names = string( fieldnames( namedArgs ) ).';
            for name = names
                obj.(name) = namedArgs.(name);
            end % for

            % Set the initial block and model parameters.
            modelName = obj.SimulinkModelName;
            setBlockParameter( obj.Simulation, ...
                modelName + "/Stiffness", ...
                "Gain", string( obj.Stiffness ) )
            setBlockParameter( obj.Simulation, ...
                modelName + "/Mass", ...
                "Gain", string( 1 / obj.Mass ) )
            setBlockParameter( obj.Simulation, ...
                modelName + "/Damping", ...
                "Gain", string( obj.DampingCoefficient ) )
            setBlockParameter( obj.Simulation, ...
                modelName + "/Initial Position", ...
                "Value", string( obj.InitialPosition ) )
            setBlockParameter( obj.Simulation, ...
                obj.ExternalForceBlockPath, ...
                "tsamp", string( obj.InputChangeInterval ) )
            forceInputVector = "[0, 10, 20].'";
            setBlockParameter( obj.Simulation, ...
                obj.ExternalForceBlockPath, ...
                "OutValues", forceInputVector )
            setModelParameter( obj.Simulation, ...
                "StopTime", "Inf" )

        end % constructor

        function delete( obj )
            %DELETE Close the Simulink model.

            close_system( obj.SimulinkModelName, 0 )

        end % delete

        function startSimulation( obj )
            %STARTSIMULATION Start the Simulink simulation.
            
            start( obj.Simulation )

        end % startSimulation

        function varargout = stopSimulation( obj )
            %STOPSIMULATION Stop the Simulink simulation.

            nargoutchk( 0, 1 )
            simOut = stop( obj.Simulation );            
            if nargout == 1
                varargout{1} = simOut;
            end % if

        end % stopSimulation

        function set.Stiffness( obj, value )

            obj.Stiffness = value;
            obj.modifyParameterDuringSimulation( ...
                obj.SimulinkModelName + "/Stiffness", ...
                "Gain", string( obj.Stiffness ) )

        end % set.Stiffness

        function set.Mass( obj, value )

            obj.Mass = value;
            obj.modifyParameterDuringSimulation( ...
                obj.SimulinkModelName + "/Mass", ...
                "Gain", string( 1 / obj.Mass ) )

        end % set.Mass       

        function set.DampingCoefficient( obj, value )

            obj.DampingCoefficient = value;
            obj.modifyParameterDuringSimulation( ...
                obj.SimulinkModelName + "/Damping", ...
                "Gain", string( obj.DampingCoefficient ) )

        end % set.DampingCoefficient

        function set.InitialPosition( obj, value )

            obj.InitialPosition = value;
            obj.modifyParameterDuringSimulation( ...
                obj.SimulinkModelName + "/Initial Position", ...
                "Value", string( obj.InitialPosition ) )

        end % set.InitialPosition

        function set.InputChangeInterval( obj, value )

            obj.InputChangeInterval = value;
            obj.modifyParameterDuringSimulation( ...
                obj.ExternalForceBlockPath, ...
                "tsamp", string( obj.InputChangeInterval ) )

        end % set.MaximumMagnitude

    end % methods

    methods ( Access = private )

        function modifyParameterDuringSimulation( obj, blockPath, ...
                paramName, paramValue )
            %MODIFYPARAMETERDURINGSIMULATION Modify the given Simulink 
            %simulation parameter when the simulation is running.

            % Update the simulation object.
            setBlockParameter( obj.Simulation, ...
                blockPath, paramName, paramValue )

        end % modifyParameterDuringSimulation

    end % methods ( Access = private )

end % classdef