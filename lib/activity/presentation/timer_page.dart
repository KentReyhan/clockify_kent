import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/activity.dart';
import '../../model/user.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/string_utils.dart';
import '../state/timer_state.dart';

class TimerPage extends StatefulWidget {
  const TimerPage(
      {super.key,
      required this.onNext,
      required this.activeUser,
      required this.inputtedActivityID});
  final int inputtedActivityID;
  final User activeUser;
  final VoidCallback onNext;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late TimerState timerState;
  Position? position;
  String? desc;
  @override
  void initState() {
    detectLocation();
    timerState = Provider.of<TimerState>(context, listen: false);
    super.initState();
  }

  detectLocation() async {
    var isGPSAvaliable = await Geolocator.isLocationServiceEnabled();
    if (!mounted) {
      return;
    }
    if (isGPSAvaliable) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (!mounted) {
        return;
      }
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'GPS Permission ditolak, mohon untuk memberi ijin lokasi untuk dapat menggunakan fitur lokasi')));
      } else if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'GPS Permission ditolak secara permanen, mohon untuk memberi ijin lokasi untuk dapat menggunakan fitur lokasi')));
      } else {
        position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('GPS Service tidak ada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Consumer<TimerState>(builder: (context, value, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                child: Text(
                  '${timerState.hour.toString().padLeft(2, '0')} : ${timerState.minute.toString().padLeft(2, '0')} : ${timerState.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 60.0),
                ),
              ),
            );
          }),
          const SizedBox(
            height: 60,
          ),
          Consumer<TimerState>(
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(45, 0, 40, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Start Time',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(StringUtils.stopWatch(timerState.startTime),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(StringUtils.dayMonthYear(timerState.startTime),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15.0)),
                      ],
                    ),
                    const SizedBox(
                      width: 100,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('End Time',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(StringUtils.stopWatch(timerState.endTime),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(StringUtils.dayMonthYear(timerState.endTime),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15.0)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Center(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(16, 16))),
                      tileColor: const Color(0XFF434B8C),
                      leading:
                          const Icon(Icons.location_on, color: Colors.yellow),
                      title: Text(
                        position == null
                            ? 'Coordinate Tidak Terdeteksi'
                            : '${position?.latitude}.${position?.longitude}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ))),
          const SizedBox(
            height: 15,
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Input ini kosong, mohon diisi';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  desc = value;
                });
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  hintText: 'Write your activity here ...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  filled: true,
                  fillColor: Colors.white),
            ),
          )),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: timerState.startState
                ? stopResetButton()
                : timerState.saveState
                    ? saveDeleteButton()
                    : startButton(),
          ),
        ],
      ),
    );
  }

  startButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
                (states) => const Color(0XFF45CDDC)),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(8, 8))))),
        child: const Text('START', style: TextStyle(color: Colors.white)),
        onPressed: () {
          setState(() {
            timerState.startTimer();
          });
        },
      ),
    );
  }

  stopResetButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 150,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0XFF45CDDC)),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(8, 8))))),
            child: const Text('STOP', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                timerState.stopTimer();
              });
            },
          ),
        ),
        //const SizedBox(width: 150,),
        SizedBox(
          width: 150,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(8, 8))))),
            child:
                const Text('RESET', style: TextStyle(color: Color(0XFFA7A6C5))),
            onPressed: () {
              timerState.resetTimer();
            },
          ),
        )
      ],
    );
  }

  saveDeleteButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 150,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0XFF45CDDC)),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(8, 8))))),
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                if (desc == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deskripsi harus diisi')));
                  return;
                } else if (position == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('GPS Error')));
                  return;
                } else if (timerState.startTime == null ||
                    timerState.endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cek Waktu Error')));
                  return;
                }
                DateTime activityDate = DateTime(timerState.startTime!.year,
                    timerState.startTime!.month, timerState.startTime!.day);
                Activity activity = Activity(
                    activityID: activityBox.length + 1,
                    userID: widget.activeUser.userID,
                    activityDesc: desc!,
                    activityDate: activityDate,
                    activityStart: timerState.startTime!,
                    activityEnd: timerState.endTime!,
                    latitude: position!.latitude,
                    longitude: position!.longitude);
                timerState.saveActivity(activity);
                timerState.resetTimer();
                timerState.startTime = null;
                timerState.endTime = null;
              });
            },
          ),
        ),
        SizedBox(
          width: 150,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(8, 8))))),
            child: const Text('DELETE',
                style: TextStyle(color: Color(0XFFA7A6C5))),
            onPressed: () {
              setState(() {
                timerState.deleteActivity(widget.inputtedActivityID);
                timerState.resetTimer();
                timerState.startTime = null;
                timerState.endTime = null;
              });
            },
          ),
        )
      ],
    );
  }
}
