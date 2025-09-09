// Go to https://jimaku.cc/login and create a new account.
// Then go to https://jimaku.cc/account and click the `Generate` button to create a new API key
// Click the `Copy` button and paste it below
var API_KEY = "";

// Configuration options
var CONFIG = {
  // Filter the response to only have the specified episode
  prompt_episode: true,

  // Subtitle suffix (e.g., ".JA" for Japanese subtitles)
  subtitle_suffix: ".JA",

  // Preferred subtitle format (order matters, first is most preferred)
  preferred_formats: ["ass", "srt", "vtt"],

  // Automatically load the subtitle after download
  auto_load: true,

  // Default subtitle delay in seconds (can be positive or negative)
  default_delay: 0,

  // Default subtitle font size
  default_font_size: 16,

  // Automatically rename the subtitle file after download
  auto_rename: true,

  // Automatically run autosubsync-mpv after downloading the subtitle
  run_auto_subsync: true
};

// Keybindings
// var MANUAL_SEARCH_KEY = "g";
var FILENAME_AUTO_SEARCH_KEY = "ctrl+J";
var PARENT_FOLDER_AUTO_SEARCH_KEY = "n";

function api(url, extraArgs) {
  var baseArgs = [
    "curl",
    "-s",
    "--url",
    url,
    "--header",
    "Authorization: " + API_KEY
  ];

  var args = Array.prototype.concat.apply(baseArgs, extraArgs);

  var res = mp.command_native({
    name: "subprocess",
    playback_only: false,
    capture_stdout: true,
    capture_stderr: true,
    args: args
  });

  if (res.stdout) return JSON.parse(res.stdout);
}

function downloadSub(sub) {
  return api(sub.url, ["--output", sub.name]);
}

function showMessage(message, persist) {
  var ass_start = mp.get_property_osd("osd-ass-cc/0");
  var ass_stop = mp.get_property_osd("osd-ass-cc/1");

  mp.osd_message(
    ass_start + "{\\fs16}" + message + ass_stop,
    persist ? 999 : 2
  );
}

// The timeout is neccessary due to a weird bug in mpv
function inputGet(args) {
  mp.input.terminate();
  setTimeout(function () {
    mp.input.get(args);
  }, 1);
}

// The timeout is neccessary due to a weird bug in mpv
function inputSelect(args) {
  mp.input.terminate();
  setTimeout(function () {
    mp.input.select(args);
  }, 1);
}

// Taken from mpv-subversive
// https://github.com/nairyosangha/mpv-subversive/blob/master/backend/backend.lua#L146
function sanitize(text) {
  var subPatterns = [
    /\.[a-zA-Z]+$/, // extension
    /\./g,
    /-/g,
    /_/g,
    /\[[^\]]+\]/g, // [] bracket
    /\([^\)]+\)/g, // () bracket
    /720[pP]/g,
    /480[pP]/g,
    /1080[pP]/g,
    /[xX]26[45]/g,
    /[bB]lu[-]?[rR]ay/g,
    /^[\s]*/,
    /[\s]*$/,
    /1920x1080/g,
    /1920X1080/g,
    /Hi10P/g,
    /FLAC/g,
    /AAC/g
  ];

  var result = text;

  subPatterns.forEach(function (subPattern) {
    var newResult = result.replace(subPattern, " ");
    if (newResult.length > 0) {
      result = newResult;
    }
  });

  return result;
}

// Adapted from mpv-subversive
// https://github.com/nairyosangha/mpv-subversive/blob/master/backend/backend.lua#L164
function extractTitle(text) {
  var matchers = [
    { regex: /^([\w\s\d]+)[Ss]\d+[Ee]?\d+/, group: 1 },
    { regex: /^([\w\s\d]+)-[\s]*\d+[\s]*[^\w]*$/, group: 1 },
    { regex: /^([\w\s\d]+)[Ee]?[Pp]?[\s]+\d+$/, group: 1 },
    { regex: /^([\w\s\d]+)[\s]\d+.*$/, group: 1 },
    { regex: /^\d+[\s]*(.+)$/, group: 1 }
  ];

  for (var i = 0; i < matchers.length; i++) {
    var matcher = matchers[i];
    var match = text.match(matcher.regex);
    if (match) {
      return match[matcher.group].trim();
    }
  }

  return text;
}

function getNames(results) {
  return results.map(function (item) {
    return item.name;
  });
}

function runAutoSubSyncMPV() {
  try {
    mp.command_native(["script-binding", "autosubsync-menu"]);
  } catch (e) {
    showMessage("autosubsync-mpv not installed");
    return;
  }
}

function selectSub(selectedSub) {
  showMessage("Downloading: " + selectedSub.name);

  try {
    downloadSub(selectedSub);

    // Get current video filename without extension
    var videoPath = mp.get_property("path");
    if (!videoPath) {
      throw new Error("No video file is currently playing");
    }
    var videoName = videoPath.substring(0, videoPath.lastIndexOf("."));

    // Get subtitle extension
    var subExt = selectedSub.name.substring(selectedSub.name.lastIndexOf("."));

    var newSubName = selectedSub.name;
    if (CONFIG.auto_rename) {
      // Create new subtitle filename
      newSubName = videoName + CONFIG.subtitle_suffix + subExt;

      // Rename the downloaded subtitle file
      var renameResult = mp.command_native({
        name: "subprocess",
        playback_only: false,
        args: ["mv", selectedSub.name, newSubName]
      });

      if (renameResult.error) {
        throw new Error(
          "Failed to rename subtitle file: " + renameResult.error
        );
      }

      showMessage(newSubName + " downloaded and renamed");
    } else {
      showMessage(newSubName + " downloaded");
    }

    if (CONFIG.auto_load) {
      mp.commandv("sub_add", newSubName);
      showMessage(newSubName + " added");

      // Apply subtitle settings if configured
      if (CONFIG.default_delay !== 0) {
        mp.commandv("sub_delay", CONFIG.default_delay);
      }
      if (CONFIG.default_font_size !== 16) {
        mp.commandv("sub_font_size", CONFIG.default_font_size);
      }
    }

    if (CONFIG.run_auto_subsync) {
      runAutoSubSyncMPV();
    }

    mp.set_property("pause", "no");
  } catch (error) {
    showMessage("Error: " + error.message, true);
    mp.set_property("pause", "no");
  }
}

function sortByPreferredFormat(files) {
  return files.sort(function (a, b) {
    var extA = a.name.substring(a.name.lastIndexOf(".") + 1).toLowerCase();
    var extB = b.name.substring(b.name.lastIndexOf(".") + 1).toLowerCase();

    var indexA = CONFIG.preferred_formats.indexOf(extA);
    var indexB = CONFIG.preferred_formats.indexOf(extB);

    if (indexA === -1) return 1;
    if (indexB === -1) return -1;
    return indexA - indexB;
  });
}

function selectEpisode(anime, episode) {
  mp.input.terminate();
  var episodeResults;

  if (episode) {
    showMessage("Fetching subs for: " + anime.name + " episode " + episode);
    episodeResults = api(
      "https://jimaku.cc/api/entries/" + anime.id + "/files?episode=" + episode
    );
  } else {
    showMessage("Fetching all subs for: " + anime.name);
    episodeResults = api(
      "https://jimaku.cc/api/entries/" + anime.id + "/files"
    );
  }

  if (episodeResults.error) {
    showMessage("Error: " + animeResults.error);
    return;
  }

  if (episodeResults.length === 0) {
    showMessage("No results found");
    return;
  }

  // Sort results by preferred format
  episodeResults = sortByPreferredFormat(episodeResults);

  if (episodeResults.length === 1) {
    var selectedEpisode = episodeResults[0];
    selectSub(selectedEpisode);
    return;
  }

  var items = getNames(episodeResults);

  inputSelect({
    prompt: "Select episode: ",
    items: items,
    submit: function (id) {
      var selectedEpisode = episodeResults[id - 1];
      selectSub(selectedEpisode);
    }
  });
}

function onAnimeSelected(anime) {
  if (CONFIG.prompt_episode) {
    inputGet({
      prompt: "Episode (leave blank for all): ",
      submit: function (episode) {
        selectEpisode(anime, episode);
      }
    });
  } else {
    selectEpisode(anime);
  }
}

function search(searchTerm, isAuto) {
  mp.input.terminate();
  showMessage('Searching for: "' + searchTerm + '"');

  var animeResults = api(
    encodeURI(
      "https://jimaku.cc/api/entries/search?anime=true&query=" + searchTerm
    )
  );

  if (animeResults.error) {
    showMessage("Error: " + animeResults.error);
    return;
  }

  if (animeResults.length === 0) {
    showMessage("No results found");
    if (isAuto) {
      manualSearch(searchTerm);
    }
    return;
  }

  if (animeResults.length === 1) {
    var selectedAnime = animeResults[0];
    onAnimeSelected(selectedAnime);
    return;
  }

  var items = getNames(animeResults);

  inputSelect({
    prompt: "Select anime: ",
    items: items,
    submit: function (id) {
      var selectedAnime = animeResults[id - 1];
      showMessage(selectedAnime.name, true);
      onAnimeSelected(selectedAnime);
    }
  });
}

function manualSearch(defaultText) {
  inputGet({
    prompt: "Search term: ",
    submit: search,
    default_text: defaultText
  });

  mp.set_property("pause", "yes");
  showMessage("Manual Jimaku Search", true);
}

function autoSearch() {
  var filename = mp.get_property("filename");
  var sanitizedFilename = sanitize(filename);
  var currentAnime = extractTitle(sanitizedFilename);

  mp.set_property("pause", "yes");

  search(currentAnime, true);
}

function autoSearchParentFolder() {
  var path = mp.get_property("stream-open-filename");
  var pathSplit = path.split(path.indexOf("/") >= 0 ? "/" : "\\");
  var filename =
    pathSplit.length === 1 ? pathSplit[0] : pathSplit[pathSplit.length - 2];

  var sanitizedFilename = sanitize(filename);
  var currentAnime = extractTitle(sanitizedFilename);

  mp.set_property("pause", "yes");

  search(currentAnime, true);
}

// mp.add_key_binding(MANUAL_SEARCH_KEY, "jimaku-manual-search", manualSearch);
mp.add_key_binding(
  FILENAME_AUTO_SEARCH_KEY,
  "jimaku-filename-auto-search",
  autoSearch
);
mp.add_key_binding(
  PARENT_FOLDER_AUTO_SEARCH_KEY,
  "jimaku-parent-folder-auto-search",
  autoSearchParentFolder
);
