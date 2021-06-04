import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef AsyncAutocompleteOptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function(TextEditingValue textEditingValue);

class AsyncRawAutocomplete<T extends Object> extends StatefulWidget {
  /// Create an instance of AsyncRawAutocomplete.
  ///
  /// [displayStringForOption], [optionsBuilder] and [optionsViewBuilder] must
  /// not be null.
  const AsyncRawAutocomplete({
    Key? key,
    required this.optionsViewBuilder,
    required this.optionsBuilder,
    this.displayStringForOption = defaultStringForOption,
    this.fieldViewBuilder,
    this.focusNode,
    this.onSelected,
    this.textEditingController,
  }) : assert(displayStringForOption != null),
       assert(
         fieldViewBuilder != null
            || (key != null && focusNode != null && textEditingController != null),
         'Pass in a fieldViewBuilder, or otherwise create a separate field and pass in the FocusNode, TextEditingController, and a key. Use the key with AsyncRawAutocomplete.onFieldSubmitted.',
        ),
       assert(optionsBuilder != null),
       assert(optionsViewBuilder != null),
       assert((focusNode == null) == (textEditingController == null)),
       super(key: key);

  /// {@template flutter.widgets.AsyncRawAutocomplete.fieldViewBuilder}
  /// Builds the field whose input is used to get the options.
  ///
  /// Pass the provided [TextEditingController] to the field built here so that
  /// AsyncRawAutocomplete can listen for changes.
  /// {@endtemplate}
  final AutocompleteFieldViewBuilder? fieldViewBuilder;

  /// The [FocusNode] that is used for the text field.
  ///
  /// {@template flutter.widgets.AsyncRawAutocomplete.split}
  /// The main purpose of this parameter is to allow the use of a separate text
  /// field located in another part of the widget tree instead of the text
  /// field built by [fieldViewBuilder]. For example, it may be desirable to
  /// place the text field in the AppBar and the options below in the main body.
  ///
  /// When following this pattern, [fieldViewBuilder] can return
  /// `SizedBox.shrink()` so that nothing is drawn where the text field would
  /// normally be. A separate text field can be created elsewhere, and a
  /// FocusNode and TextEditingController can be passed both to that text field
  /// and to AsyncRawAutocomplete.
  ///
  /// {@tool dartpad --template=freeform}
  /// This examples shows how to create an autocomplete widget with the text
  /// field in the AppBar and the results in the main body of the app.
  ///
  /// ```dart main
  /// import 'package:flutter/material.dart';
  /// import 'package:flutter/widgets.dart';
  ///
  /// void main() => runApp(const AutocompleteExampleApp());
  ///
  /// class AutocompleteExampleApp extends StatelessWidget {
  ///   const AutocompleteExampleApp({Key? key}) : super(key: key);
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return const MaterialApp(
  ///       home: AsyncRawAutocompleteSplit(),
  ///     );
  ///   }
  /// }
  ///
  /// const List<String> _options = <String>[
  ///   'aardvark',
  ///   'bobcat',
  ///   'chameleon',
  /// ];
  ///
  /// class AsyncRawAutocompleteSplit extends StatefulWidget {
  ///   const AsyncRawAutocompleteSplit({Key? key}) : super(key: key);
  ///
  ///   @override
  ///   AsyncRawAutocompleteSplitState createState() => AsyncRawAutocompleteSplitState();
  /// }
  ///
  /// class AsyncRawAutocompleteSplitState extends State<AsyncRawAutocompleteSplit> {
  ///   final TextEditingController _textEditingController = TextEditingController();
  ///   final FocusNode _focusNode = FocusNode();
  ///   final GlobalKey _autocompleteKey = GlobalKey();
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Scaffold(
  ///       appBar: AppBar(
  ///         // This is where the real field is being built.
  ///         title: TextFormField(
  ///           controller: _textEditingController,
  ///           focusNode: _focusNode,
  ///           decoration: const InputDecoration(
  ///             hintText: 'Split AsyncRawAutocomplete App',
  ///           ),
  ///           onFieldSubmitted: (String value) {
  ///             AsyncRawAutocomplete.onFieldSubmitted<String>(_autocompleteKey);
  ///           },
  ///         ),
  ///       ),
  ///       body: Align(
  ///         alignment: Alignment.topLeft,
  ///         child: AsyncRawAutocomplete<String>(
  ///           key: _autocompleteKey,
  ///           focusNode: _focusNode,
  ///           textEditingController: _textEditingController,
  ///           optionsBuilder: (TextEditingValue textEditingValue) {
  ///             return _options.where((String option) {
  ///               return option.contains(textEditingValue.text.toLowerCase());
  ///             }).toList();
  ///           },
  ///           optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
  ///             return Material(
  ///               elevation: 4.0,
  ///               child: ListView(
  ///                 children: options.map((String option) => GestureDetector(
  ///                   onTap: () {
  ///                     onSelected(option);
  ///                   },
  ///                   child: ListTile(
  ///                     title: Text(option),
  ///                   ),
  ///                 )).toList(),
  ///               ),
  ///             );
  ///           },
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  /// {@endtemplate}
  ///
  /// If this parameter is not null, then [textEditingController] must also be
  /// not null.
  final FocusNode? focusNode;

  /// {@template flutter.widgets.AsyncRawAutocomplete.optionsViewBuilder}
  /// Builds the selectable options widgets from a list of options objects.
  ///
  /// The options are displayed floating below the field using a
  /// [CompositedTransformFollower] inside of an [Overlay], not at the same
  /// place in the widget tree as [AsyncRawAutocomplete].
  /// {@endtemplate}
  final AutocompleteOptionsViewBuilder<T> optionsViewBuilder;

  /// {@template flutter.widgets.AsyncRawAutocomplete.displayStringForOption}
  /// Returns the string to display in the field when the option is selected.
  ///
  /// This is useful when using a custom T type and the string to display is
  /// different than the string to search by.
  ///
  /// If not provided, will use `option.toString()`.
  /// {@endtemplate}
  final AutocompleteOptionToString<T> displayStringForOption;

  /// {@template flutter.widgets.AsyncRawAutocomplete.onSelected}
  /// Called when an option is selected by the user.
  ///
  /// Any [TextEditingController] listeners will not be called when the user
  /// selects an option, even though the field will update with the selected
  /// value, so use this to be informed of selection.
  /// {@endtemplate}
  final AutocompleteOnSelected<T>? onSelected;

  /// {@template flutter.widgets.AsyncRawAutocomplete.optionsBuilder}
  /// A function that returns the current selectable options objects given the
  /// current TextEditingValue.
  /// {@endtemplate}
  final AsyncAutocompleteOptionsBuilder<T> optionsBuilder;

  /// The [TextEditingController] that is used for the text field.
  ///
  /// {@macro flutter.widgets.AsyncRawAutocomplete.split}
  ///
  /// If this parameter is not null, then [focusNode] must also be not null.
  final TextEditingController? textEditingController;

  /// Calls [AutocompleteFieldViewBuilder]'s onFieldSubmitted callback for the
  /// AsyncRawAutocomplete widget indicated by the given [GlobalKey].
  ///
  /// This is not typically used unless a custom field is implemented instead of
  /// using [fieldViewBuilder]. In the typical case, the onFieldSubmitted
  /// callback is passed via the [AutocompleteFieldViewBuilder] signature. When
  /// not using fieldViewBuilder, the same callback can be called by using this
  /// static method.
  ///
  /// See also:
  ///
  ///  * [focusNode] and [textEditingController], which contain a code example
  ///    showing how to create a separate field outside of fieldViewBuilder.
  static void onFieldSubmitted<T extends Object>(GlobalKey key) {
    final _AsyncRawAutocompleteState<T> AsyncrawAutocomplete = key.currentState! as _AsyncRawAutocompleteState<T>;
    AsyncrawAutocomplete._onFieldSubmitted();
  }

  /// The default way to convert an option to a string in
  /// [displayStringForOption].
  ///
  /// Simply uses the `toString` method on the option.
  static String defaultStringForOption(dynamic option) {
    return option.toString();
  }

  @override
  _AsyncRawAutocompleteState<T> createState() => _AsyncRawAutocompleteState<T>();
}

class _AsyncRawAutocompleteState<T extends Object> extends State<AsyncRawAutocomplete<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _optionsLayerLink = LayerLink();
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  Iterable<T> _options = Iterable<T>.empty();
  T? _selection;

  // The OverlayEntry containing the options.
  OverlayEntry? _floatingOptions;

  // True iff the state indicates that the options should be visible.
  bool get _shouldShowOptions {
    return _focusNode.hasFocus && _selection == null && _options.isNotEmpty;
  }

  // Called when _textEditingController changes.
  void _onChangedField() async {
    final Iterable<T> options = await widget.optionsBuilder(
      _textEditingController.value,
    );
    _options = options;
    if (_selection != null
        && _textEditingController.text != widget.displayStringForOption(_selection!)) {
      _selection = null;
    }
    _updateOverlay();
  }

  // Called when the field's FocusNode changes.
  void _onChangedFocus() {
    _updateOverlay();
  }

  // Called from fieldViewBuilder when the user submits the field.
  void _onFieldSubmitted() {
    if (_options.isEmpty) {
      return;
    }
    _select(_options.first);
  }

  // Select the given option and update the widget.
  void _select(T nextSelection) {
    if (nextSelection == _selection) {
      return;
    }
    _selection = nextSelection;
    final String selectionString = widget.displayStringForOption(nextSelection);
    _textEditingController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: selectionString.length),
      text: selectionString,
    );
    widget.onSelected?.call(_selection!);
  }

  // Hide or show the options overlay, if needed.
  void _updateOverlay() {
    if (_shouldShowOptions) {
      _floatingOptions?.remove();
      _floatingOptions = OverlayEntry(
        builder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _optionsLayerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            child: widget.optionsViewBuilder(context, _select, _options),
          );
        },
      );
      Overlay.of(context, rootOverlay: true)!.insert(_floatingOptions!);
    } else if (_floatingOptions != null) {
      _floatingOptions!.remove();
      _floatingOptions = null;
    }
  }

  // Handle a potential change in textEditingController by properly disposing of
  // the old one and setting up the new one, if needed.
  void _updateTextEditingController(TextEditingController? old, TextEditingController? current) {
    if ((old == null && current == null) || old == current) {
      return;
    }
    if (old == null) {
      _textEditingController.removeListener(_onChangedField);
      _textEditingController.dispose();
      _textEditingController = current!;
    } else if (current == null) {
      _textEditingController.removeListener(_onChangedField);
      _textEditingController = TextEditingController();
    } else {
      _textEditingController.removeListener(_onChangedField);
      _textEditingController = current;
    }
    _textEditingController.addListener(_onChangedField);
  }

  // Handle a potential change in focusNode by properly disposing of the old one
  // and setting up the new one, if needed.
  void _updateFocusNode(FocusNode? old, FocusNode? current) {
    if ((old == null && current == null) || old == current) {
      return;
    }
    if (old == null) {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode.dispose();
      _focusNode = current!;
    } else if (current == null) {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode = FocusNode();
    } else {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode = current;
    }
    _focusNode.addListener(_onChangedFocus);
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.textEditingController ?? TextEditingController();
    _textEditingController.addListener(_onChangedField);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onChangedFocus);
    SchedulerBinding.instance!.addPostFrameCallback((Duration _) {
      _updateOverlay();
    });
  }

  @override
  void didUpdateWidget(AsyncRawAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTextEditingController(
      oldWidget.textEditingController,
      widget.textEditingController,
    );
    _updateFocusNode(oldWidget.focusNode, widget.focusNode);
    SchedulerBinding.instance!.addPostFrameCallback((Duration _) {
      _updateOverlay();
    });
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onChangedField);
    if (widget.textEditingController == null) {
      _textEditingController.dispose();
    }
    _focusNode.removeListener(_onChangedFocus);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _floatingOptions?.remove();
    _floatingOptions = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _fieldKey,
      child: CompositedTransformTarget(
        link: _optionsLayerLink,
        child: widget.fieldViewBuilder == null
            ? const SizedBox.shrink()
            : widget.fieldViewBuilder!(
                context,
                _textEditingController,
                _focusNode,
                _onFieldSubmitted,
              ),
      ),
    );
  }
}