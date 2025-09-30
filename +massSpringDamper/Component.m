classdef Component < matlab.ui.componentcontainer.ComponentContainer
    %COMPONENT Superclass for massSpringDamper view/controller implementation.

    % Model-related properties.
    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
        % CategorySelected Listener.
        CategorySelectedListener(:, 1) event.listener {mustBeScalarOrEmpty}
        % PredictionMade Listener.
        PredictionMadeListener(:,1) event.listener {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )

end % classdef