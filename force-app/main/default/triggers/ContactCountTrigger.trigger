trigger ContactCountTrigger on Contact (after insert, after update, after delete) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        Registered_Guesses.updateRegisteredGuesses(Trigger.new, false);
    }
    if (Trigger.isDelete) {
        Registered_Guesses.updateRegisteredGuesses(Trigger.old, true);
    }
}
