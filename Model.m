classdef Model < handle
    %MODEL Data model for the mass-spring-damper model app.


    properties ( Constant )
        % Name of Simulink Model.
        SimulinkModelName = "MassSpringDamperModel"
    end % properties ( Constant )

    properties
        % Simulation Inputs.
        SimulationInput(1, 1) Simulink.SimulationInput
        % Simulation Outputs.
        SimulationOutput(1, 1) Simulink.SimulationOutput
        % Stiffness
        Stiffness(1, 1) double = 100
        % Mass
        Mass(1, 1) double = 10
        % Damping
        Damping(1, 1) double = 1
        % Initial Position
        InitialPosition(1, 1) double = 0
        % Random Stream Value
        RandomStreamValue(1, 1) double = 0
        % Random Stream For Force Input.
        RandomStream(1, 1) RandStream = RandStream("mt19937ar", "Seed", 0);
        % Maximum Magnitude Value.
        MaximumMagnitude(1, 1) double = 100
        % Input Change Interval.
        InputChangeInterval(1, 1) double = 100
    end % properties ( SetAccess = private )

    methods 

        function obj = Model
            %MODEL Constructs the massSpringDamper model.

            % Start Simulink
            start_simulink
          
        end

        function StartStopSimulation( obj )
            if simulink.compiler.getSimulationStatus(obj.SimulinkModelName) == slsim.SimulationStatus.Inactive
                obj.SimulationInput = obj.createSimulationInput();
                obj.SimulationOutput = sim(obj.SimulationInput);
            else
                simulink.compiler.stopSimulation(obj.SimulinkModelName)
            end % if
        end % function StartStopSimulation

        function simInp = createSimulationInput( obj )
            % Create an empty SimulationInput Object.
            simInp = Simulink.SimulationInput(obj.SimulinkModelName);

            % Specify External Inputs.
            %simInp = simulink.compiler.setExternalInputsFcn(simInp, @(varargin) obj.setInput(varargin{:}));

            % Load the parameters values from the ui edit fields
            simInp = simInp.setVariable('k',obj.Stiffness, 'Workspace', 'MassSpringDamperModel');
            simInp = simInp.setVariable('m',obj.Mass, 'Workspace', 'MassSpringDamperModel');
            simInp = simInp.setVariable('b',obj.Damping, 'Workspace', 'MassSpringDamperModel');
            simInp = simInp.setVariable('x0',obj.InitialPosition, 'Workspace', 'MassSpringDamperModel');
            
            % Since sim will run forever, turn off (or limit) data logging
            simInp = simInp.setModelParameter('StopTime','inf');
            
            simInp = simulink.compiler.configureForDeployment(simInp);

            % create a rand stream used to generate force input values
            obj.RandomStream = ...
                RandStream("mt19937ar", "Seed", obj.RandomStreamValue);
        end % function createSimulationInput

        function forceInput = setInput( obj , varargin)
            % Magnitude of the input force
            ur01 = rand(obj.RandomStream);
            forceInputMag = 2*obj.MaximumMagnitude*(0.5-ur01);

            forceInput = repmat(forceInputMag, 1, obj.InputChangeInterval);
        end % function setInput

        function modifyParameterDuringSim ( obj , paramName, paramValue)
            ss = simulink.compiler.getSimulationStatus(obj.SimulinkModelName);
            if ( ss ~= slsim.SimulationStatus.Running && ...
                    ss ~= slsim.SimulationStatus.Paused)
                return;
            end % if
            slv = Simulink.Simulation.Variable(paramName, paramValue);
            simulink.compiler.modifyParameters(obj.SimulinkModelName, slv)
            if paramName == "m"
                obj.Mass = paramValue;
            elseif paramName == "k"
                obj.Stiffness = paramValue;
            else 
                obj.Damping = paramValue;
            end % if
        end % function modifyParameterDuringSim

        function changeMass ( obj , newValue)
            obj.Mass = newValue;
            obj.modifyParameterDuringSim("m", obj.Mass);
        end % function changeMass

        function changeStiffness ( obj , newValue)
            obj.Stiffness = newValue;
            obj.modifyParameterDuringSim("k", obj.Stiffness);
        end % function changeStiffness

        function changeDamping ( obj , newValue)
            obj.Damping = newValue;
            obj.modifyParameterDuringSim("b", obj.Damping);
        end % function changeDamping


    end % methods

end % class definition