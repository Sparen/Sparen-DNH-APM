# Sparen's Danmakufu Application Monitoring System

Welcome to the repository for Sparen's Danmakufu Application Monitoring System! This system aims to track statistics over the lifetime of a script, outputting a report on request.

### Usage

To use the APM, you will first need to find a Stage Script (or Plural or Single) to monitor.

In `@Loading` for the script of your choice, do the following:

```
@Loading {
    let apm = LoadScript(GetCurrentScriptDirectory() ~ "./../SparenDNHAPM.dnh");
    //Set Common Data
    StartScript(apm);
}
```

Adjust the parameter of `LoadScript()` to the path to `SparenDNHAPM.dnh`. Once you've set all of the CommonData, run `StartScript()` to begin the APM script.

At the end of your script, you will need to notify the APM that it needs to generate its report. To do this, use NotifyEventAll. By default, the APM uses `EV_USER_STAGE + 2048` and will output to `GetCurrentScriptDirectory() ~ "./dnhapm-output/"`.

### Customization

The APM uses CommonData in the "dnhapm" area for configuration. To set configuration, `SetAreaCommonData("dnhapm", "FieldToAdjust", New Value);` in `@Loading` between `LoadScript()`, which initializes the Common Data Area, and `StartScript()`, which runs the script with the specified parameters.

#### Basic Configuration
```
EVENT_DNHAPM_FINALIZE = GetAreaCommonData("dnhapm", "FinalizeEvent", EV_USER_STAGE + 2048);
OUTPUT_DIRECTORY = GetAreaCommonData("dnhapm", "OutputDirectory", GetCurrentScriptDirectory() ~ "./dnhapm-output/");
SCRIPT_NAME = GetAreaCommonData("dnhapm", "ScriptName", "--Unnamed Script--");
ENABLE_AGGREGATE = GetAreaCommonData("dnhapm", "EnableAggregate", true);
GRAPH_SCALE = GetAreaCommonData("dnhapm", "GraphScale", 1);
```

Basic configuration for the APM allows you to set the Event that is used to trigger writing the report (defaults to `EV_USER_STAGE + 2048`), the output directory of the report (defaults to `GetCurrentScriptDirectory() ~ "./dnhapm-output/"`), and the name of the script within the report (defaults to `"--Unnamed Script--"`).

Aggregate will load past data in the OUTPUT_DIRECTORY into the graphs (defaults to `true`). GRAPH_SCALE is the scale of the x axis of the graph (defaults to `1`, or one pixel per second). This means that a 5 minute script will fit into 300 pixels at default scale, or 600 pixels at a scale of 2.

#### Specific Configuration

By default, the APM will log everything specified, but there are Common Data to disable these features. Within each feature set, there are a number of different fields that can be adjusted.

This section will be populated with data as new features are implemented.

### Downloads

This project is currently under construction and is not yet recommended for use. 

Official Releases will be provided via GitHub releases.

### Contributing and Credits

Improvements and bug reports should be submitted via GitHub issues.

