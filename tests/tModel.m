classdef tModel < matlab.unittest.TestCase
    %TMODEL Tests for massSpringDamper.Model.

    % Copyright 2025-2026 The MathWorks, Inc.

    properties ( Access = private )
        % Application data model under test.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function assertConstructorIsWarningFree( testCase )

            f = @() massSpringDamper.Model();
            testCase.fatalAssertWarningFree( f, ...
                "The massSpringDamper.Model constructor was not " + ...
                "warning-free." )

        end % assertConstructorIsWarningFree

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function setupModel( testCase )

            testCase.Model = massSpringDamper.Model();
            testCase.addTeardown( @() delete( testCase.Model ) )

        end % setupModel

    end % methods ( TestMethodSetup )

    methods ( Test )

        function tConstructorLoadsSystem( testCase )

            testCase.verifyTrue( testCase.Model.Simulation.LoadModel, ...
                "The constructor did not load the Simulink model." )

        end % tConstructorLoadsSystem

        function tConstructorLoadsCorrectSystem( testCase )

            testCase.verifyEqual( testCase.Model.Simulation.ModelName, ...
                "MassSpringDamperModel", ...
                "The constructor did not load the Simulink model " + ...
                "'MassSpringDamperModel'." )

        end % tConstructorLoadsCorrectSystem

        function tConstructorAcceptsNamedArguments( testCase )

            % Create the model, specifying values for the tunable
            % variables.
            M = massSpringDamper.Model( "Mass", 10, ...
                "DampingCoefficient", 5, ...
                "InitialPosition", 0.2, ...
                "Stiffness", 12 );
            testCase.addTeardown( @() delete( M ) )

            % Verify the model properties have been set correctly.
            testCase.verifyEqual( M.Mass, 10, ...
                "The 'Mass' property was not set correctly by " + ...
                "the constructor." )
            testCase.verifyEqual( M.DampingCoefficient, 5, ...
                "The 'DampingCoefficient' property was not set " + ...
                "correctly by the constructor." )
            testCase.verifyEqual( M.InitialPosition, 0.2, ...
                "The 'InitialPosition' property was not set " + ...
                "correctly by the constructor." )
            testCase.verifyEqual( M.Stiffness, 12, ...
                "The 'Stiffness' property was not set " + ...
                "correctly by the constructor." )

        end % tConstructorAcceptsNamedArguments

        function tStartSimulationUpdatesSimulation( testCase )

            % Start the simulation and verify the simulation status.
            testCase.Model.startSimulation()
            testCase.addTeardown( @() testCase.Model.Simulation.stop() )
            testCase.verifyEqual( testCase.Model.Simulation.Status, ...
                "running", ...
                "The startSimulation() method did not start " + ...
                "the simulation." )

        end % tStartSimulationUpdatesSimulation

        function tStopSimulationUpdatesSimulation( testCase )

            % Stop the simulation and verify the simulation status.
            testCase.Model.startSimulation()
            testCase.Model.stopSimulation()
            testCase.verifyEqual( testCase.Model.Simulation.Status, ...
                "inactive", ...
                "The stopSimulation() method did not stop " + ...
                "the simulation." )

        end % tStopSimulationUpdatesSimulation

        function tSettingMassUpdatesSimulation( testCase )

            testCase.Model.Mass = 50;
            t = tabulateVariables( testCase.Model );
            [tf, loc] = ismember( "m", t.Name );
            testCase.assertTrue( tf, "The mass (m) is not " + ...
                "present in the simulation variables." )
            m = str2double( string( t.Value(loc) ) );
            testCase.verifyEqual( m, 50, ...
                "Setting the 'Mass' model property did not " + ...
                "update the corresponding simulation variable." )

        end % tSettingMassUpdatesSimulation

        function tSettingStiffnessUpdatesSimulation( testCase )

            testCase.Model.Stiffness = 5;
            t = tabulateVariables( testCase.Model );
            [tf, loc] = ismember( "k", t.Name );
            testCase.assertTrue( tf, "The stiffness (k) is not " + ...
                "present in the simulation variables." )
            k = str2double( string( t.Value(loc) ) );
            testCase.verifyEqual( k, 5, ...
                "Setting the 'Stiffness' model property did not " + ...
                "update the corresponding simulation variable." )

        end % tSettingStiffnessUpdatesSimulation

        function tSettingDampingCoefficientUpdatesSimulation( testCase )

            testCase.Model.DampingCoefficient = 1.5;
            t = tabulateVariables( testCase.Model );
            [tf, loc] = ismember( "b", t.Name );
            testCase.assertTrue( tf, "The damping coefficient (b) " + ...
                "is not present in the simulation variables." )
            b = str2double( string( t.Value(loc) ) );
            testCase.verifyEqual( b, 1.5, ...
                "Setting the 'DampingCoefficient' model property " + ...
                "did not update the corresponding simulation variable." )

        end % tSettingDampingCoefficientUpdatesSimulation

        function tSettingInitialPositionUpdatesSimulation( testCase )

            testCase.Model.InitialPosition = 0;
            t = tabulateVariables( testCase.Model );
            [tf, loc] = ismember( "x0", t.Name );
            testCase.assertTrue( tf, "The initial position (x0) " + ...
                "is not present in the simulation variables." )
            x0 = str2double( string( t.Value(loc) ) );
            testCase.verifyEqual( x0, 0, ...
                "Setting the 'InitialPosition' model property " + ...
                "did not update the corresponding simulation variable." )

        end % tSettingInitialPositionUpdatesSimulation
        
    end % methods ( Test )

end % classdef