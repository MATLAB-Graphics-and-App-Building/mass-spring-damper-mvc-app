classdef Model < handle
    %MODEL Data model for the mass-spring-damper model app.


    properties ( SetAccess = immutable )
        % Name of Simulink Model.
        SimulinkModelName(1, 1) string
    end

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
        % Maximum Magnitude Value.
        MaximumMagnitude(1, 1) double = 100
        % Input Change Interval.
        %InputChangeInterval(1, 1) double = 100
    end % properties

    properties ( SetAccess = private )
        % Simulation Time.
        SimTime(1, 1) double = 0
        % External Force Data.
        ExtForceData(1, :) timeseries = []
        % Position Data.
        PosData(1, :) timeseries = []
        % Velocity Data.
        VelData(1, :) timeseries = []
        % Acceleration Data.
        AccData(1, :) timeseries = []
        % Simulation Status.
        SimulationStatus(1, 1) slsim.SimulationStatus = 'Inactive'
    end % properties ( SetAccess = private )

    events ( NotifyAccess = private)
        % The simulation status has changed.
        StatusChanged
        % The simulation step has run.
        SimulationStepDone
    end % events ( NotifyAccess = private )

    methods

        function obj = Model( modelName )
            %MODEL Constructs the massSpringDamper model.

            % Start Simulink
            start_simulink

            % Set the name of the model.
            obj.SimulinkModelName = modelName;


        end

        function StartSimulation( obj )
            assert(simulink.compiler.getSimulationStatus(obj.SimulinkModelName) == slsim.SimulationStatus.Inactive)
            obj.SimTime = 0;
            obj.SimulationInput = obj.createSimulationInput();
            obj.SimulationOutput = sim(obj.SimulationInput);
        end % function StartSimulation( obj )

        function StopSimulation( obj )
            assert(simulink.compiler.getSimulationStatus(obj.SimulinkModelName) == slsim.SimulationStatus.Active)
            simulink.compiler.stopSimulation(obj.SimulinkModelName)
        end % function StartStopSimulation

        function simInp = createSimulationInput( obj )
            % Create an empty SimulationInput Object.
            simInp = Simulink.SimulationInput(obj.SimulinkModelName);

            % Setting a Status changed Function.
            simInp = simulink.compiler.setSimulationStatusChangeFcn(simInp,...
                @(simStatus) obj.simStatusChanged(simStatus));

            % Specify External Inputs.
            simInp = simulink.compiler.setExternalInputsFcn(simInp, @obj.setInput);

            % PostStepFcn is used to update plots
            simInp = simulink.compiler.setPostStepFcn(simInp, ...
                @(simTime) obj.postSimulationStep(simTime));

            % Load the parameters values from the ui edit fields
            simInp = simInp.setVariable('k',obj.Stiffness, 'Workspace', 'MassSpringDamperModel');
            simInp = simInp.setVariable('m',obj.Mass, 'Workspace', 'MassSpringDamperModel');
            simInp = simInp.setVariable('b',obj.Damping, 'Workspace', 'MassSpringDamperModel');
            simInp = simInp.setVariable('x0',obj.InitialPosition, 'Workspace', 'MassSpringDamperModel');

            % Since sim will run forever, turn off (or limit) data logging
            simInp = simInp.setModelParameter('StopTime','inf');

            simInp = simulink.compiler.configureForDeployment(simInp);

        end % function createSimulationInput

        function simStatusChanged ( obj, simStatus )
            obj.SimulationStatus = simStatus;
            obj.notify( "StatusChanged" )
        end % function simStatusChanged

        function postSimulationStep ( obj, simTime )
            obj.SimTime = simTime;
            % obj.SimTime  = simulink.compiler.getSimulationTime(obj.SimulinkModelName);
            % Complete the pace obj.SimPace = obj.SimTime/
            obj.SimulationOutput = simulink.compiler.getSimulationOutput(obj.SimulinkModelName);
            obj.ExtForceData = obj.SimulationOutput.logsout{1}.Values;
            obj.PosData = obj.SimulationOutput.logsout{2}.Values;
            obj.VelData = obj.SimulationOutput.logsout{3}.Values;
            obj.AccData = obj.SimulationOutput.logsout{4}.Values;
            obj.notify("SimulationStepDone")
        end

        function forceInput = setInput( obj , ~, simTime)
            % Magnitude of the input force
            % ur01 = rand;
            % forceInput = 2*obj.MaximumMagnitude*(0.5-ur01);
            forceInput = 5;
            obj.ExtForceData.Time = simTime;
            obj.ExtForceData.Data = forceInput;
            %
            % forceInput = repmat(forceInputMag, 1, obj.InputChangeInterval);
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

        function checkState( obj )
            assert(simulink.compiler.getSimulationStatus(obj.SimulinkModelName) == slsim.SimulationStatus.Inactive);
        end % function checkState( obj )

    end % methods

end % class definition