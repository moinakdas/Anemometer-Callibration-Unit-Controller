%%%%%%%%%%%%%%%%% INIT MOTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadphidget21;
stepperHandle = libpointer('int32Ptr');
calllib('phidget21', 'CPhidgetStepper_create', stepperHandle);
calllib('phidget21', 'CPhidget_open', stepperHandle, -1);

valPtr = libpointer('int64Ptr', 0);

%wait for motor to attach
if calllib('phidget21', 'CPhidget_waitForAttachment', stepperHandle, 2500) == 0
    disp('Stepper Recognized');

    t = timer('TimerFcn','disp(''waiting...'')', 'StartDelay', 1.0);

    %set parameters for stepper motor in index 0 (velocity, acceleration, current)
    %these values were set basd on some testing based on a 1063 and a stepper motor I had here to test with
    %might need to modify these values for your particular case
    calllib('phidget21', 'CPhidgetStepper_setVelocityLimit', stepperHandle, 0, 20536);
    calllib('phidget21', 'CPhidgetStepper_setAcceleration', stepperHandle, 0, 87543);
    calllib('phidget21', 'CPhidgetStepper_setCurrentLimit', stepperHandle, 0, 1);

    start(t);
    wait(t);

    disp('Engage Motor 0');

    %engage the stepper motor in index 0
    calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 1);
    start(t);
    wait(t);

    calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, valPtr);
    currPosition = get(valPtr, 'Value');
    disp('Stepper Engaged');
%%%%%%%%%%%%%%%%%%%%%%%%% MOVING THE STEPPER MOTOR %%%%%%%%%%%%%%%%%%%%%

    %set motor to position 1 (20000)
    calllib('phidget21', 'CPhidgetStepper_setTargetPosition', stepperHandle, 0, 20000);

    %wait for motor to arrive
    while currPosition < 20000
        calllib('phidget21', 'CPhidgetStepper_getCurrentPosition', stepperHandle, 0, valPtr);
        currPosition = get(valPtr, 'Value');
    end
    disp('Motor reached target');

    start(t);
    wait(t);

    disp('Disengage Motor 0');

    %disengage the stepper motor in index 0
    calllib('phidget21', 'CPhidgetStepper_setEngaged', stepperHandle, 0, 0);
    start(t);
    wait(t);
else
    disp('Could Not Open Stepper');
end

disp('Closing Stepper');
% clean up
calllib('phidget21', 'CPhidget_close', stepperHandle);
calllib('phidget21', 'CPhidget_delete', stepperHandle);

disp('Closed Stepper');