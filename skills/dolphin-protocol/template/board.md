# Dolphin Board

Live signals only — current state, not history. Resolved signals are
removed (CLAIMs on RELEASE, tasks on DONE) and archived by the memory
keeper at milestone close.

Send signals ONLY with the `dolphin-say` script:

    dolphin-say <from> @<target|all> <VERB> <object> -- <one-line note>
    (board line becomes: @target VERB object | note [from:<from> time])

Verbs: TASK HANDOFF CLAIM RELEASE REVIEW DONE BLOCKED ACK NOTE
A signal without an ACK is not received.

---
