import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Providers/gym.dart';
import 'package:provider/provider.dart';

class AddExerciseForm extends StatefulWidget {
  const AddExerciseForm({Key? key}) : super(key: key);

  @override
  _AddExerciseFormState createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final Map<String, String> _data = {
    'group': '',
    'name': '',
    'category': '',
  };
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final gym = Provider.of<Gym>(context);
    return Expanded(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              "Add An Exercise",
              style: Theme.of(context).textTheme.headline1,
            ),
            // Spacing
            const SizedBox(
              height: 15,
            ),
            // Select exercise group
            Text(
              "Exercise Group",
              style: Theme.of(context).textTheme.headline6,
            ),
            // Spacing
            const SizedBox(
              height: 10,
            ),
            // Drop down to select group
            DropDownTextField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Field cannot be empty";
                }

                return null;
              },
              dropDownList: gym.groupNames
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList(),
              onChanged: (value) {
                if (value.toString().isNotEmpty) {
                  _data['group'] = value.value.toString();
                } else {
                  _data['group'] = '';
                }
              },
            ),
            // Spacing
            const SizedBox(
              height: 10,
            ),
            // Enter Exercise Name
            Text(
              "Exercise Name",
              style: Theme.of(context).textTheme.headline6,
            ),
            // Spacing
            const SizedBox(
              height: 10,
            ),
            // Enter Exercise Name
            TextFormField(
              decoration:
                  const InputDecoration(hintText: "Type in an exercise"),
              onChanged: (value) => _data['name'] = value.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Field cannot be empty";
                }
                var isValid =
                    gym.validateExercises(_data['group']!, _data['name']!);
                return isValid;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            // Select exercise category (weights or not)
            Text(
              "Category",
              style: Theme.of(context).textTheme.headline6,
            ),
            // Spacing
            const SizedBox(
              height: 10,
            ),
            // Drop down to select group
            DropDownTextField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Field cannot be empty";
                }

                return null;
              },
              dropDownList: const [
                DropDownValueModel(name: 'Weights', value: 'Weights'),
                DropDownValueModel(name: 'Body Weight', value: 'Body Weight'),
              ],
              onChanged: (value) {
                if (value.toString().isNotEmpty) {
                  _data['category'] = value.value.toString();
                } else {
                  _data['category'] = '';
                }
              },
            ),
            // Spacing
            const SizedBox(
              height: 20,
            ),
            // Add Exercise
            ElevatedButton(
              onPressed: () async {
                bool isValid = _formKey.currentState!.validate();
                if (isValid) {
                  // Add exercise
                  try {
                    await gym.addExercise(
                        _data['group']!, _data['name']!, _data['category']!);
                    Navigator.of(context).pop();
                  } catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                            "An error occured adding an exercise. Please try again later,"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
