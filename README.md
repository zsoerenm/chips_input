# chips_input

Flutter library for building input fields with InputChips as input options.

## Usage

### Installation

Follow installation instructions [here](https://pub.dartlang.org/packages/flutter_chips_input#-installing-tab-)

### Import

```dart
import 'package:flutter_chips_input/flutter_chips_input.dart';
```

### Example

#### ChipsInput

First create some sort of Class that holds the data. You could also use a simple String.
```dart
class AppProfile {
  final String name;
  final String email;
  final String imageUrl;

  const AppProfile(this.name, this.email, this.imageUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}
```

Initialize some data and implement the ChipsInput Widget to your liking.
```dart
const mockResults = <AppProfile>[
    AppProfile('John Doe', 'jdoe@flutter.io',
        'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
    AppProfile('Paul', 'paul@google.com',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Fred', 'fred@google.com',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Brian', 'brian@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('John', 'john@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Thomas', 'thomas@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Nelly', 'nelly@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Marie', 'marie@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Charlie', 'charlie@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Diana', 'diana@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Ernie', 'ernie@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    AppProfile('Gina', 'fred@flutter.io',
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
];

ChipsInput(
    maxChips: 3,
    initialValue: [mockResults[1]],
    findSuggestions: (String query) {
        if (query.isNotEmpty) {
            var lowercaseQuery = query.toLowerCase();
            final results = mockResults.where((profile) {
            return profile.name
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                profile.email
                    .toLowerCase()
                    .contains(query.toLowerCase());
            }).toList(growable: false)
            ..sort((a, b) => a.name
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(
                    b.name.toLowerCase().indexOf(lowercaseQuery)));
            return results;
        }
        return mockResults;
    },
    onChanged: (data) {
        print(data);
    },
    chipBuilder: (context, state, AppProfile profile) {
        return InputChip(
            key: ObjectKey(profile),
            label: Text(profile.name),
            avatar: CircleAvatar(
            backgroundImage: NetworkImage(profile.imageUrl),
            ),
            onDeleted: () => state.deleteChip(profile),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    },
    suggestionBuilder: (context, AppProfile profile) {
        return ListTile(
            key: ObjectKey(profile),
            leading: CircleAvatar(
            backgroundImage: NetworkImage(profile.imageUrl),
            ),
            title: Text(profile.name),
            subtitle: Text(profile.email),
        );
    },
)
```

## Credit

* Danvick Miller for the package [flutter_chips_input](https://github.com/danvick/flutter_chips_input)