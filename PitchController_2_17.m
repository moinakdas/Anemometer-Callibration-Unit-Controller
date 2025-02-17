loadphidget21;
stepper_control;
%330,000 steps

function stepper_control
    % Initialize the stepper motor
    stepperHandle = initialize();
    % Move to a specific position (example: 20000)
    moveto(stepperHandle, 330000);
    % Cleanup after operation
    cleanup(stepperHandle);
end

%%%%%%%%%%%%%%%%%%%%%% INITIALIZATION FUNCTION %%%%%%%%%%%%%%%%%%%%%%
function stepperHandle = initialize()
    disp('Initializing Stepper Motor...');
    
    stepperHandle = libpointer('int32Ptr');
    calllib('phidget21', 'CPhidgetStepper_create', stepperHandle);
    calllib('phidget21', 'CPhidget_open', stepperHandle, -1);

    if calllib('phidget21', 'CPhidget_waitForAttachment', stepperHandle, 2500) == 0
        disp('Stepper Recognized');

        % Set motor parameters
        calllib('phidget21', 'CPhidgetStepper_setVelocityLimit', stepperHandle, 0, 20536);
        calllib('phidget21', 'CPhidgetStepper_setAcceleration', stepperHandle, 0, 87543);
        calllib('phidget21', 'CPhidgetStepper_setCurrentLimit', stepperHandle, 0, 1);

        % Engage the motor
        calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 1);
        disp('Stepper Engaged');
    else
        error('Could Not Open Stepper');
    end
end

%%%%%%%%%%%%%%%%%%%%%% MOVEMENT FUNCTION %%%%%%%%%%%%%%%%%%%%%%


function moveto(stepperHandle, targetPosition)
    disp(['Moving to position: ', num2str(targetPosition)]);

    valPtr = libpointer('int64Ptr', 0);
    calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, valPtr);
    currPosition = get(valPtr, 'Value');

    calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, targetPosition);

    % Wait for the motor to reach the target position
    while currPosition ~= targetPosition
        calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, valPtr);
        currPosition = get(valPtr, 'Value');
    end

    disp('Motor reached target');
end

%%%%%%%%%%%%%%%%%%%%%% CLEANUP FUNCTION %%%%%%%%%%%%%%%%%%%%%%
function cleanup(stepperHandle)
    disp('Disengaging and closing Stepper...');

    % Disengage motor
    calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 0);

    % Close and delete stepper handle
    calllib('phidget21', 'CPhidget_close', stepperHandle);
    calllib('phidget21', 'CPhidget_delete', stepperHandle);

    disp('Stepper Closed');
end
