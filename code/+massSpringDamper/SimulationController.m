classdef SimulationController < massSpringDamper.MassSpringDamperComponent
    %SIMULATIONCONTROLLER Control simulation inputs and parameters.

    % Copyright 2025-2026 The MathWorks, Inc.

    properties ( Access = private )
        % Grid layout for the various simulation controls.
        Grid(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        % Controls for starting and stopping the simulation.
        StartStopControls(:, 1) simulink.ui.control.SimulationControls ...
            {mustBeScalarOrEmpty}
        % Simulation progress indicator.
        ProgressIndicator(:, 1) simulink.ui.control.SimulationProgress ...
            {mustBeScalarOrEmpty}
        % Button for saving the simulation output.
        SaveButton(:, 1) simulink.ui.control.SaveOutputButton ...
            {mustBeScalarOrEmpty}
        % Variable tuner, for tuning the mass, stiffness, damping
        % coefficient, and input change interval.
        Tuner(:, 1) simulink.ui.control.VariableTuner {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = SimulationController( model, namedArgs )
            %SIMULATIONCONTROLLER Construct a SimulationController object,
            %given the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.SimulationController
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@massSpringDamper.MassSpringDamperComponent( model )

            % Connect the controls to the simulation object.
            set( [obj.StartStopControls, ...
                obj.ProgressIndicator, ...
                obj.SaveButton, ...
                obj.Tuner], "Simulation", obj.Model.Simulation )

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            % Create the main layout.
            obj.Grid = uigridlayout( "Parent", obj, ...
                "ColumnWidth", {100, "1x", "fit"}, ...
                "RowHeight", {50, "1x"}, ...
                "Padding", 5, ...
                "RowSpacing", 5, ...
                "ColumnSpacing", 5 );

            % Add the simulation controls.
            obj.StartStopControls = uisimcontrols( ...
                "Parent", obj.Grid );

            % Add the simulation progress bar.
            obj.ProgressIndicator = uisimprogress( ...
                "Parent", obj.Grid );

            % Add the simulation export button.
            obj.SaveButton = uisimdatabutton( ...
                "Parent", obj.Grid, ...
                "OutputFilename", "MassSpringDamperOutput.mat" );

            % Add the variable tuner.
            obj.Tuner = uisimvartuner( "Parent", obj.Grid );
            obj.Tuner.Layout.Column = [1, 3];

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

    end % methods ( Access = protected )   

end % classdef