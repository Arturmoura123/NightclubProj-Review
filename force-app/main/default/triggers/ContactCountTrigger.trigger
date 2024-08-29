trigger ContactCountTrigger on Contact (after insert, after delete) {
    if (Trigger.isInsert) {
        Registered_Guesses.updateRegisteredGuesses(Trigger.new, false);
    }
    if (Trigger.isDelete) {
        Registered_Guesses.updateRegisteredGuesses(Trigger.old, true);
    }
}
