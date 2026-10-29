# The Haunted Creature Registry (Activity 11, Undergraduate Track)

Three-screen Flutter app: **Welcome (Foyer) → Signup (Laboratory) → Success (Ballroom)**.


## Setup
```bash
flutter pub add animated_text_kit
flutter pub add confetti
flutter run
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

## File layout
```
lib/
|- main.dart                  (app shell only)
`- screens/
   |- welcome_screen.dart     (foyer, typewriter title, push)
   |- signup_screen.dart      (lab, validators, dropdown, toggle, date picker, loading)
   `- success_screen.dart     (ballroom, confetti, personalized message)
```

## Navigation
- Foyer → Lab uses `Navigator.push`, so Back returns to the Foyer.
- Lab → Ballroom uses `Navigator.pushReplacement`, so the Lab is removed from the stack and Back cannot resubmit.
- "Back to the Foyer" uses `popUntil((route) => route.isFirst)`.
- Name and creature type are passed to `SuccessScreen` through constructor parameters.

## Ghost Hunt test table
Fill the **Observed** column from your own run and attach screenshots in the Word document.

| # | Case | Expected | Observed |
|---|------|----------|----------|
| 1 | Empty fields, tap Register Creature | Errors on name, email, password, birth date, creature type | |
| 2 | Pick each of the 5 creatures | Chosen creature shown on Success screen with name | |
| 3 | Email without @, password under 6 chars | Correct error under each field | |
| 4 | Eye toggle | Password shows as letters, then hides again; validator still works | |
| 5 | Date picker | No future date selectable; empty date blocks submit | |
| 6 | Back from the Lab | Returns to Foyer; typed values gone | |
| 7 | System Back from the Ballroom | Does not return to the form | |
| 8 | Double-tap Register during loading | Only one navigation | |
| 9 | Confetti | Fires once on arrival; leaving and returning does not crash | |

## Concepts (rewrite in your own words)
- **Stack:** _push keeps the old screen under the new one; pushReplacement swaps it out. Tie this to your Foyer/Lab/Ballroom flow._
- **State lifetime:** _the controllers, `_obscurePassword`, `_birthDate`, and `_selectedCreatureType` live in `_SignupScreenState` and die with the Lab. Only `userName` and `creatureType` survive, because they are passed into `SuccessScreen`._
- **dispose:** _`_SignupScreenState.dispose()` releases four controllers and `_SuccessScreenState.dispose()` releases the `ConfettiController`; forgetting causes leaks and "setState after dispose" errors._

## Bug log
| Symptom | Suspected cause | Fix |
|---------|-----------------|-----|
| _(add any ghost you found)_ | | |

## Ghost Hunt I (answer any two; pick from the prompts below and add your own evidence)

### 1. The Reversed Trapdoor
**Prediction (pushReplacement):** After one submit the stack is `[Foyer, Success]`. Submitting again is impossible because the form is gone. System Back at the Ballroom exits to the Foyer, not the form.

**Prediction (push):** After each submission the stack grows by one Ballroom: `[Foyer, Lab, Ballroom]`. Back at the Ballroom returns to the Lab, where the form can be submitted again, so a guest can register repeatedly.

**Observed:** _Change `pushReplacement` to `push` in `signup_screen.dart`, run it, and screenshot what Back does. Then reconcile with the predictions above, and change it back._

### 2. The Poltergeist Field
| Value | Where it lives | After rotation |
|-------|----------------|----------------|
| Name, email, password text | `TextEditingController`s in `_SignupScreenState` | _observe_ |
| Password visibility | `_obscurePassword` in State | _observe_ |
| Birth date | `_birthDate` in State, mirrored in `_dateController` | _observe_ |
| Creature type | `_selectedCreatureType` in State | _observe_ |

_Rotate the emulator mid-signup, record which values disappeared, and explain why using State lifetime. Propose the smallest fix._ Note: the dropdown reads `value: _selectedCreatureType`, so check whether it still displays after rotation.

### 3. The Clairvoyant Ghost (date picker boundary tests)
| Input | Expected | Observed |
|-------|----------|----------|
| Open picker | Opens on 2008 | |
| Pick a date in 1990 | Selectable | |
| Pick the earliest year (1920) | Selectable | |
| Try a future date | Not selectable | |
| Submit with no date | "Pick your birth date" | |

### 4. The Twin Mansions
_Predict the compiler error for two `SuccessScreen` declarations, then write a one-sentence naming rule._