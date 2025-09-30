classdef Component < matlab.ui.componentcontainer.ComponentContainer
    %COMPONENT Superclass for massSpringDamper view/controller implementation.

    % Model-related properties.
    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
        % StatusChanged Listener.
        StatusChangedListener(:, 1) event.listener {mustBeScalarOrEmpty}
        % SimulationStepDone Listener.
        SimulationStepDoneListener(:,1) event.listener {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )


    methods

        function obj = Component( model )
            %COMPONENT Construct a component, given the model.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
            end % arguments ( Input )

            % Call the superclass constructor. This creates an un-Parented
            % component, and sets the component to span its parent when
            % this is assigned.
            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                "Parent", [], ...
                "Units", "normalized", ...
                "Position", [0, 0, 1, 1] )

            % Assign the model.
            obj.Model = model;

            % Create StatusChangedListener.
            obj.StatusChangedListener = listener( obj.Model, ...
                "StatusChanged", @obj.onStatusChanged );

            % Create SimulationStepDoneListener.
            obj.SimulationStepDoneListener = listener(obj.Model,...
                "SimulationStepDone",@obj.onSimulationStepDone);

        end % constructor

    end % methods

    methods ( Abstract, Access = protected )

        onStatusChanged( obj, s, e )
        onSimulationStepDone( obj, s, e )

    end % methods ( Abstract, Access = protected )

end % class definition