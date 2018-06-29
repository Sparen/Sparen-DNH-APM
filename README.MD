# Sparen's Danmakufu Application Monitoring System

Welcome to the repository for Sparen's Danmakufu Application Monitoring System! This system aims to track statistics over the lifetime of a script, outputting a report on request. 

This software is capable of profiling a single run of a script and monitoring behavior as well as aggregating data over multiple runs of a script, providing average case data as well as other visualizations. 

# Usage

To use the APM, you will first need to find a Stage Script (or Plural or Single) to monitor or profile.

In `@Loading` for the script of your choice, do the following:

```java
@Loading {
    let apm = LoadScript(GetCurrentScriptDirectory() ~ "./../SparenDNHAPM.dnh");
    //Set Common Data
    StartScript(apm);
}
```

Adjust the parameter of `LoadScript()` to the path to `SparenDNHAPM.dnh`. Once you've set all of the CommonData, run `StartScript()` to begin the APM script.

Example below:
```java
@Loading {
    let apm = LoadScript(GetCurrentScriptDirectory() ~ "./../../SparenDNHAPM.dnh");
    SetAreaCommonData("dnhapm", "OutputDirectory", GetCurrentScriptDirectory() ~ "./../dnhapm-output/");
    SetAreaCommonData("dnhapm", "ScriptName", "Moonstruck Magician");
    SetAreaCommonData("dnhapm", "GraphScale", 3);
    SetAreaCommonData("dnhapm", "GrazeUpdateFreq", 6);
    SetAreaCommonData("dnhapm", "UserNoteSlots", 3);
    StartScript(apm);
}
```

At the end of your script (before it closes on regular termination/player death), you will need to notify the APM that it needs to generate its report. To do this, use NotifyEventAll. By default, the APM uses `EV_USER_STAGE + 2048` and will output to `GetCurrentScriptDirectory() ~ "./dnhapm-output/"`.

Example below:
```java
task StageOver {
    while(!finished && GetPlayerState() != STATE_END){yield;}
    NotifyEventAll(EV_USER_STAGE + 2048, "");
    loop(60){yield;}
    ...
    CloseStgScene();
}
```

Modified CSV files as well as HTML files will be generated in the target directory. The CSV files, if kept, will allow for successive runs of the APM to log past data should aggregation be enabled. The HTML files contain the reports.

This script works when saves as part of a replay, but replays made before the profiler was implemented will desync when run after the profiler has been added.

Typically, DNHAPM only needs to run in one script. If you wish to transition to a production or release environment after using the APM, all you need to do is block comment out the setup in `@Loading`, as the only other code needed to run DNHAMP will be Event calls in other scripts, which have minimal overhead.

For usage examples, refer to `test/*`.

# Customization

The APM uses CommonData in the "dnhapm" area for configuration. To set configuration, `SetAreaCommonData("dnhapm", "FieldToAdjust", New Value);` in `@Loading` between `LoadScript()`, which initializes the Common Data Area, and `StartScript()`, which runs the script with the specified parameters.

## Basic Configuration
```java
EVENT_DNHAPM_FINALIZE = GetAreaCommonData("dnhapm", "FinalizeEvent", EV_USER_STAGE + 2048);
OUTPUT_DIRECTORY = GetAreaCommonData("dnhapm", "OutputDirectory", GetCurrentScriptDirectory() ~ "./dnhapm-output/");
SCRIPT_NAME = GetAreaCommonData("dnhapm", "ScriptName", "--Unnamed Script--");
ENABLE_AGGREGATE = GetAreaCommonData("dnhapm", "EnableAggregate", true);
GRAPH_SCALE = GetAreaCommonData("dnhapm", "GraphScale", 2);
AGGREGATE_LINE_OPACITY = GetAreaCommonData("dnhapm", "AggregateLineOpacity", 0.25);
```

Basic configuration for the APM allows you to set the Event that is used to trigger writing the report (defaults to `EV_USER_STAGE + 2048`), the output directory of the report (defaults to `GetCurrentScriptDirectory() ~ "./dnhapm-output/"`), and the name of the script within the report (defaults to `"--Unnamed Script--"`).

Aggregate will load past data in the OUTPUT_DIRECTORY into the graphs (defaults to `true`). GRAPH_SCALE is the scale of the x axis of the graph (defaults to `2`, or two pixel per second). This means that a 5 minute script will fit into 300 pixels at a scale of 1, or 600 pixels at a scale of 2 (default).

In regards to aggregate data, this program assumes that the settings for prior runs were the same (i.e. it assumes that update frequencies, graph scale, etc. were the same as the current run). Former runs will appear with opacity equal to AGGREGATE_LINE_OPACITY (defaults to alpha of 0.25). It is recommended that you use a different output directory for each script to monitor. 

## Specific Configuration

By default, the APM will log everything specified, but there are Common Data to disable these features. Within each feature set, there are a number of different fields that can be adjusted.

This section will be populated with data as new features are implemented.

### FPS Monitoring
<p align="center">
    <img src="./sample-metric/fpsexample.png">
    <i>Sample FPS graph, showing lag spikes at plural loading and spellcard declaration</i>
</p>

```java
FEATURE_FPS_ENABLE = GetAreaCommonData("dnhapm", "FPSEnable", true);
FEATURE_FPS_UPDATEFREQ = GetAreaCommonData("dnhapm", "FPSUpdateFreq", 10);
FEATURE_FPS_LINECOLOR = GetAreaCommonData("dnhapm", "FPSLineColor", "#2266FF");
```

For FPS Monitoring, there are three fields - one for enabling the feature, one for the update frequency (defaults to every 10 frames), and one for the line color in the graphs (defaults to #2266FF).

For FPS Monitoring, note that Danmakufu internally updates FPS infrequently, so even with an update frequency of every 10 frames, you will get very straight lines.

### Graze Monitoring
```java
FEATURE_GRAZE_ENABLE = GetAreaCommonData("dnhapm", "GrazeEnable", true);
FEATURE_GRAZE_UPDATEFREQ = GetAreaCommonData("dnhapm", "GrazeUpdateFreq", 10);
FEATURE_GRAZE_LINECOLOR = GetAreaCommonData("dnhapm", "GrazeLineColor", "#887777");
```

For Graze Monitoring, similarly to FPS Monitoring, there are three fields - one for enabling the feature, one for the update frequency (defaults to every 10 frames), and one for the line color in the graphs (defaults to #887777).

For Graze Monitoring, note that the default update frequency will result in a less smooth chart, but should nevertheless provide a good approximation for longer scripts.

### Score Monitoring
```java
FEATURE_SCORE_ENABLE = GetAreaCommonData("dnhapm", "ScoreEnable", true);
FEATURE_SCORE_UPDATEFREQ = GetAreaCommonData("dnhapm", "ScoreUpdateFreq", 10);
FEATURE_SCORE_LINECOLOR = GetAreaCommonData("dnhapm", "ScoreLineColor", "#FF5555");
```

For Score Monitoring, similarly to FPS and Graze Monitoring, there are three fields - one for enabling the feature, one for the update frequency (defaults to every 10 frames), and one for the line color in the graphs (defaults to #FF5555).

For Score Monitoring, like Graze Monitoring, note that the default update frequency will result in a less smooth chart, but should nevertheless provide a good approximation for longer scripts.

In addition, note that score is often player dependent and this metric is therefore primarily applicable in games with a proper scoring system.

## Report Generating
The report generated by the APM by default provides the start time of data recording as well as the player. In addition, arbitrary text can be inserted into the first part of the report with USER_TEXT.

Use `SetAreaCommonData("dnhapm", "UserText", "");` to set the user text, which should be in proper HTML. You could technically override the existing CSS styles and inject JavaScript into the HTML body this way, but I advise against it.

The system also allows for an arbitrary number of user notes. These user notes are per-run and only reflect the last run of the script.

```java
USER_NOTE_SLOTS = GetAreaCommonData("dnhapm", "UserNoteSlots", 2);
EVENT_USER_NOTE = GetAreaCommonData("dnhapm", "UserNoteEvent", EV_USER_STAGE + 2050);
ENABLE_NOTE_LINE = GetAreaCommonData("dnhapm", "EnableNoteLine", true);
```

There are 2 note slots by default, and notes render at the bottom of the graph. By default, `EV_USER_STAGE + 2050` is used to write notes to the monitoring system. 

For example:
```java
NotifyEventAll(EV_USER_STAGE + 2050, ["0", "Start"]);
```
This writes the "Start" note to note slot 0 (note slots are zero-indexed, and are passed as strings rather than integers).

Another example, for making note of when certain attacks start - in this case a spellcard:
```java
@Initialize {
    objBoss = ObjEnemy_Create(OBJ_ENEMY_BOSS);
    ObjEnemy_Regist(objBoss);
    CutIn(objBoss, "KORO", "Magic Sign \"The Glowing Waves of the Moon and Stars (N)\"", 5, BossCutIn, 0, 1, 384, 384);
    NotifyEventAll(EV_USER_STAGE + 2050, ["1", "S3N"]);
    ObjEnemyBossScene_StartSpell(objScene);
    ...
}
```

When using the note system, please be careful of text length. If your graph scale is small, if your notes are large, and/or if your notes are closely spaced together, text may overlap and become hard to read. It may therefore be helpful to abbreviate your notes (e.g. "Midboss Spell 2" - "MS2", etc.).

By default, all notes have a line dropped down from the x axis to their height for easy identification. The ENABLE_NOTE_LINE field adds another line up from the x axis to the top of the graph (in a lighter tone) for easier distinction where a note was placed. Depending on how you use the APM's notes, this may allow you to chunk the graph into 'phases' for easier analysis.

# Current and Planned Features

Current:
* FPS Monitoring  
* Graze Monitoring  
* Score Minitoring  
* User Notes  

Planned: 
* Death and Bomb Monitoring  
* Item Monitoring (requires proper integrations)  
* Spellcard graph overlay (may only be usable on non-aggregate setups)  
* Combined graphs (stretch goal)  

# Downloads

Official Releases are provided via GitHub releases.

# Contributing and Credits

Improvements and bug reports should be submitted via GitHub issues.

