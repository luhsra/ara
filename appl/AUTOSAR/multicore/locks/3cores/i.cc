/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"


// TODO: wie geht das für multicore?
#if TRACE_JSON
{
  "vertices": {
    "0": 3,
    "1": 2,
    "2": 2,
    "3": 3,
    "4": 3,
    "5": 2,
    "6": 2,
    "7": 3,
    "8": 3,
    "9": 3,
    "10": 3,
    "11": 3,
    "12": 3,
    "13": 3,
    "14": 3,
    "15": 3,
    "16": 3,
    "17": 3,
    "18": 3,
    "19": 3,
    "20": 3,
    "21": 3,
    "22": 3,
    "23": 3,
    "24": 3,
    "25": 3,
    "26": 3,
    "27": 3,
    "28": 3,
    "29": 3,
    "30": 3,
    "31": 3,
    "32": 3,
    "33": 3,
    "34": 3,
    "35": 3,
    "36": 3,
    "37": 3,
    "38": 3,
    "39": 3,
    "40": 3,
    "41": 3,
    "42": 3,
    "43": 3,
    "44": 3,
    "45": 3,
    "46": 3,
    "47": 3,
    "48": 3,
    "49": 3,
    "50": 3,
    "51": 3,
    "52": 3,
    "53": 3,
    "54": 3,
    "55": 3,
    "56": 3,
    "57": 3,
    "58": 3,
    "59": 3,
    "60": 3,
    "61": 3,
    "62": 3,
    "63": 3,
    "64": 3,
    "65": 3,
    "66": 3,
    "67": 3,
    "68": 3,
    "69": 3,
    "70": 3,
    "71": 3,
    "72": 3,
    "73": 3,
    "74": 3,
    "75": 3,
    "76": 3,
    "77": 3,
    "78": 3,
    "79": 3,
    "80": 3,
    "81": 3,
    "82": 3,
    "83": 3,
    "84": 3,
    "85": 3,
    "86": 3,
    "87": 3,
    "88": 3,
    "89": 3,
    "90": 3,
    "91": 3,
    "92": 3,
    "93": 3,
    "94": 3,
    "95": 3,
    "96": 3,
    "97": 3,
    "98": 3,
    "99": 3,
    "100": 3,
    "101": 3,
    "102": 3,
    "103": 3,
    "104": 3,
    "105": 3,
    "106": 3,
    "107": 3,
    "108": 3,
    "109": 3,
    "110": 3,
    "111": 3,
    "112": 3,
    "113": 3,
    "114": 3,
    "115": 3,
    "116": 3,
    "117": 3,
    "118": 3,
    "119": 3,
    "120": 3,
    "121": 3,
    "122": 3,
    "123": 3,
    "124": 3,
    "125": 3,
    "126": 3,
    "127": 3,
    "128": 3,
    "129": 3,
    "130": 3,
    "131": 3,
    "132": 3,
    "133": 3,
    "134": 3,
    "135": 3,
    "136": 3,
    "137": 3,
    "138": 3,
    "139": 3,
    "140": 3,
    "141": 3,
    "142": 3,
    "143": 3,
    "144": 3,
    "145": 3,
    "146": 3,
    "147": 3,
    "148": 3,
    "149": 3,
    "150": 3,
    "151": 3,
    "152": 3,
    "153": 3,
    "154": 3,
    "155": 3,
    "156": 3,
    "157": 3,
    "158": 3,
    "159": 3,
    "160": 3,
    "161": 3,
    "162": 3,
    "163": 3,
    "164": 3,
    "165": 3,
    "166": 3,
    "167": 3,
    "168": 3,
    "169": 3,
    "170": 3,
    "171": 3,
    "172": 3,
    "173": 3,
    "174": 3,
    "175": 3,
    "176": 3,
    "177": 3,
    "178": 3,
    "179": 3,
    "180": 3,
    "181": 3,
    "182": 3,
    "183": 3,
    "184": 3,
    "185": 3,
    "186": 3,
    "187": 3,
    "188": 3,
    "189": 3,
    "190": 3,
    "191": 3,
    "192": 3,
    "193": 3,
    "194": 3,
    "195": 3,
    "196": 3,
    "197": 3,
    "198": 3,
    "199": 3,
    "200": 3,
    "201": 3,
    "202": 3,
    "203": 3,
    "204": 3
  },
  "edges": [
    [
      "0",
      "1"
    ],
    [
      "0",
      "1"
    ],
    [
      "0",
      "3"
    ],
    [
      "0",
      "5"
    ],
    [
      "0",
      "9"
    ],
    [
      "0",
      "13"
    ],
    [
      "0",
      "201"
    ],
    [
      "1",
      "2"
    ],
    [
      "2",
      "3"
    ],
    [
      "2",
      "5"
    ],
    [
      "3",
      "4"
    ],
    [
      "4",
      "7"
    ],
    [
      "4",
      "7"
    ],
    [
      "4",
      "5"
    ],
    [
      "4",
      "5"
    ],
    [
      "4",
      "11"
    ],
    [
      "4",
      "15"
    ],
    [
      "5",
      "6"
    ],
    [
      "6",
      "9"
    ],
    [
      "6",
      "11"
    ],
    [
      "6",
      "13"
    ],
    [
      "6",
      "15"
    ],
    [
      "6",
      "193"
    ],
    [
      "6",
      "195"
    ],
    [
      "6",
      "197"
    ],
    [
      "6",
      "199"
    ],
    [
      "6",
      "201"
    ],
    [
      "7",
      "8"
    ],
    [
      "8",
      "5"
    ],
    [
      "8",
      "5"
    ],
    [
      "8",
      "193"
    ],
    [
      "8",
      "195"
    ],
    [
      "8",
      "197"
    ],
    [
      "8",
      "199"
    ],
    [
      "9",
      "10"
    ],
    [
      "10",
      "17"
    ],
    [
      "10",
      "17"
    ],
    [
      "10",
      "19"
    ],
    [
      "10",
      "19"
    ],
    [
      "10",
      "21"
    ],
    [
      "10",
      "21"
    ],
    [
      "11",
      "12"
    ],
    [
      "12",
      "23"
    ],
    [
      "12",
      "23"
    ],
    [
      "12",
      "25"
    ],
    [
      "12",
      "25"
    ],
    [
      "13",
      "14"
    ],
    [
      "14",
      "27"
    ],
    [
      "14",
      "27"
    ],
    [
      "14",
      "29"
    ],
    [
      "14",
      "29"
    ],
    [
      "14",
      "31"
    ],
    [
      "14",
      "31"
    ],
    [
      "15",
      "16"
    ],
    [
      "16",
      "33"
    ],
    [
      "16",
      "33"
    ],
    [
      "16",
      "35"
    ],
    [
      "16",
      "35"
    ],
    [
      "16",
      "37"
    ],
    [
      "16",
      "37"
    ],
    [
      "16",
      "30"
    ],
    [
      "17",
      "18"
    ],
    [
      "18",
      "39"
    ],
    [
      "18",
      "39"
    ],
    [
      "18",
      "41"
    ],
    [
      "18",
      "41"
    ],
    [
      "18",
      "43"
    ],
    [
      "18",
      "43"
    ],
    [
      "18",
      "45"
    ],
    [
      "18",
      "45"
    ],
    [
      "19",
      "20"
    ],
    [
      "20",
      "47"
    ],
    [
      "20",
      "47"
    ],
    [
      "20",
      "49"
    ],
    [
      "20",
      "49"
    ],
    [
      "21",
      "22"
    ],
    [
      "22",
      "51"
    ],
    [
      "22",
      "51"
    ],
    [
      "22",
      "53"
    ],
    [
      "22",
      "53"
    ],
    [
      "22",
      "55"
    ],
    [
      "22",
      "55"
    ],
    [
      "22",
      "32"
    ],
    [
      "23",
      "24"
    ],
    [
      "24",
      "57"
    ],
    [
      "24",
      "57"
    ],
    [
      "24",
      "59"
    ],
    [
      "24",
      "59"
    ],
    [
      "24",
      "61"
    ],
    [
      "24",
      "61"
    ],
    [
      "24",
      "63"
    ],
    [
      "24",
      "63"
    ],
    [
      "24",
      "194"
    ],
    [
      "25",
      "26"
    ],
    [
      "26",
      "65"
    ],
    [
      "26",
      "65"
    ],
    [
      "26",
      "67"
    ],
    [
      "26",
      "67"
    ],
    [
      "26",
      "38"
    ],
    [
      "27",
      "28"
    ],
    [
      "28",
      "69"
    ],
    [
      "28",
      "69"
    ],
    [
      "28",
      "71"
    ],
    [
      "28",
      "71"
    ],
    [
      "28",
      "73"
    ],
    [
      "28",
      "73"
    ],
    [
      "28",
      "75"
    ],
    [
      "28",
      "75"
    ],
    [
      "29",
      "30"
    ],
    [
      "30",
      "33"
    ],
    [
      "30",
      "35"
    ],
    [
      "30",
      "37"
    ],
    [
      "30",
      "33"
    ],
    [
      "30",
      "35"
    ],
    [
      "30",
      "37"
    ],
    [
      "31",
      "32"
    ],
    [
      "32",
      "51"
    ],
    [
      "32",
      "53"
    ],
    [
      "32",
      "55"
    ],
    [
      "32",
      "51"
    ],
    [
      "32",
      "53"
    ],
    [
      "32",
      "55"
    ],
    [
      "33",
      "34"
    ],
    [
      "34",
      "77"
    ],
    [
      "34",
      "77"
    ],
    [
      "34",
      "79"
    ],
    [
      "34",
      "79"
    ],
    [
      "34",
      "81"
    ],
    [
      "34",
      "81"
    ],
    [
      "34",
      "83"
    ],
    [
      "34",
      "83"
    ],
    [
      "34",
      "72"
    ],
    [
      "35",
      "36"
    ],
    [
      "36",
      "85"
    ],
    [
      "36",
      "85"
    ],
    [
      "36",
      "87"
    ],
    [
      "36",
      "87"
    ],
    [
      "36",
      "89"
    ],
    [
      "36",
      "89"
    ],
    [
      "36",
      "91"
    ],
    [
      "36",
      "91"
    ],
    [
      "36",
      "200"
    ],
    [
      "37",
      "38"
    ],
    [
      "38",
      "65"
    ],
    [
      "38",
      "67"
    ],
    [
      "38",
      "65"
    ],
    [
      "38",
      "67"
    ],
    [
      "39",
      "40"
    ],
    [
      "40",
      "93"
    ],
    [
      "40",
      "93"
    ],
    [
      "40",
      "95"
    ],
    [
      "40",
      "95"
    ],
    [
      "40",
      "97"
    ],
    [
      "40",
      "97"
    ],
    [
      "40",
      "99"
    ],
    [
      "40",
      "99"
    ],
    [
      "40",
      "48"
    ],
    [
      "41",
      "42"
    ],
    [
      "42",
      "95"
    ],
    [
      "42",
      "95"
    ],
    [
      "42",
      "99"
    ],
    [
      "42",
      "99"
    ],
    [
      "43",
      "44"
    ],
    [
      "44",
      "101"
    ],
    [
      "44",
      "101"
    ],
    [
      "44",
      "103"
    ],
    [
      "44",
      "103"
    ],
    [
      "44",
      "105"
    ],
    [
      "44",
      "105"
    ],
    [
      "44",
      "107"
    ],
    [
      "44",
      "107"
    ],
    [
      "44",
      "56"
    ],
    [
      "45",
      "46"
    ],
    [
      "46",
      "103"
    ],
    [
      "46",
      "103"
    ],
    [
      "46",
      "105"
    ],
    [
      "46",
      "105"
    ],
    [
      "47",
      "48"
    ],
    [
      "48",
      "93"
    ],
    [
      "48",
      "95"
    ],
    [
      "48",
      "97"
    ],
    [
      "48",
      "99"
    ],
    [
      "48",
      "93"
    ],
    [
      "48",
      "95"
    ],
    [
      "48",
      "97"
    ],
    [
      "48",
      "99"
    ],
    [
      "49",
      "50"
    ],
    [
      "50",
      "109"
    ],
    [
      "50",
      "109"
    ],
    [
      "50",
      "111"
    ],
    [
      "50",
      "111"
    ],
    [
      "50",
      "54"
    ],
    [
      "51",
      "52"
    ],
    [
      "52",
      "113"
    ],
    [
      "52",
      "113"
    ],
    [
      "52",
      "115"
    ],
    [
      "52",
      "115"
    ],
    [
      "52",
      "117"
    ],
    [
      "52",
      "117"
    ],
    [
      "52",
      "119"
    ],
    [
      "52",
      "119"
    ],
    [
      "52",
      "74"
    ],
    [
      "53",
      "54"
    ],
    [
      "54",
      "109"
    ],
    [
      "54",
      "111"
    ],
    [
      "54",
      "109"
    ],
    [
      "54",
      "111"
    ],
    [
      "55",
      "56"
    ],
    [
      "56",
      "101"
    ],
    [
      "56",
      "103"
    ],
    [
      "56",
      "105"
    ],
    [
      "56",
      "107"
    ],
    [
      "56",
      "101"
    ],
    [
      "56",
      "103"
    ],
    [
      "56",
      "105"
    ],
    [
      "56",
      "107"
    ],
    [
      "57",
      "58"
    ],
    [
      "58",
      "121"
    ],
    [
      "58",
      "121"
    ],
    [
      "58",
      "123"
    ],
    [
      "58",
      "123"
    ],
    [
      "58",
      "125"
    ],
    [
      "58",
      "125"
    ],
    [
      "58",
      "127"
    ],
    [
      "58",
      "127"
    ],
    [
      "58",
      "94"
    ],
    [
      "59",
      "60"
    ],
    [
      "60",
      "123"
    ],
    [
      "60",
      "123"
    ],
    [
      "60",
      "125"
    ],
    [
      "60",
      "125"
    ],
    [
      "61",
      "62"
    ],
    [
      "62",
      "129"
    ],
    [
      "62",
      "129"
    ],
    [
      "62",
      "131"
    ],
    [
      "62",
      "131"
    ],
    [
      "62",
      "86"
    ],
    [
      "63",
      "64"
    ],
    [
      "64",
      "129"
    ],
    [
      "64",
      "129"
    ],
    [
      "64",
      "133"
    ],
    [
      "64",
      "133"
    ],
    [
      "64",
      "131"
    ],
    [
      "64",
      "131"
    ],
    [
      "64",
      "135"
    ],
    [
      "64",
      "135"
    ],
    [
      "64",
      "68"
    ],
    [
      "64",
      "88"
    ],
    [
      "65",
      "66"
    ],
    [
      "66",
      "137"
    ],
    [
      "66",
      "137"
    ],
    [
      "66",
      "139"
    ],
    [
      "66",
      "139"
    ],
    [
      "66",
      "82"
    ],
    [
      "67",
      "68"
    ],
    [
      "68",
      "129"
    ],
    [
      "68",
      "133"
    ],
    [
      "68",
      "131"
    ],
    [
      "68",
      "135"
    ],
    [
      "68",
      "129"
    ],
    [
      "68",
      "133"
    ],
    [
      "68",
      "131"
    ],
    [
      "68",
      "135"
    ],
    [
      "68",
      "88"
    ],
    [
      "69",
      "70"
    ],
    [
      "70",
      "77"
    ],
    [
      "70",
      "77"
    ],
    [
      "70",
      "83"
    ],
    [
      "70",
      "83"
    ],
    [
      "71",
      "72"
    ],
    [
      "72",
      "77"
    ],
    [
      "72",
      "79"
    ],
    [
      "72",
      "81"
    ],
    [
      "72",
      "83"
    ],
    [
      "72",
      "77"
    ],
    [
      "72",
      "79"
    ],
    [
      "72",
      "81"
    ],
    [
      "72",
      "83"
    ],
    [
      "73",
      "74"
    ],
    [
      "74",
      "113"
    ],
    [
      "74",
      "115"
    ],
    [
      "74",
      "117"
    ],
    [
      "74",
      "119"
    ],
    [
      "74",
      "113"
    ],
    [
      "74",
      "115"
    ],
    [
      "74",
      "117"
    ],
    [
      "74",
      "119"
    ],
    [
      "75",
      "76"
    ],
    [
      "76",
      "119"
    ],
    [
      "76",
      "119"
    ],
    [
      "76",
      "115"
    ],
    [
      "76",
      "115"
    ],
    [
      "77",
      "78"
    ],
    [
      "78",
      "141"
    ],
    [
      "78",
      "141"
    ],
    [
      "78",
      "143"
    ],
    [
      "78",
      "143"
    ],
    [
      "79",
      "80"
    ],
    [
      "80",
      "143"
    ],
    [
      "80",
      "143"
    ],
    [
      "80",
      "141"
    ],
    [
      "80",
      "141"
    ],
    [
      "80",
      "145"
    ],
    [
      "80",
      "145"
    ],
    [
      "80",
      "147"
    ],
    [
      "80",
      "147"
    ],
    [
      "80",
      "90"
    ],
    [
      "81",
      "82"
    ],
    [
      "82",
      "137"
    ],
    [
      "82",
      "139"
    ],
    [
      "82",
      "137"
    ],
    [
      "82",
      "139"
    ],
    [
      "83",
      "84"
    ],
    [
      "84",
      "137"
    ],
    [
      "84",
      "137"
    ],
    [
      "85",
      "86"
    ],
    [
      "86",
      "129"
    ],
    [
      "86",
      "131"
    ],
    [
      "86",
      "129"
    ],
    [
      "86",
      "131"
    ],
    [
      "87",
      "88"
    ],
    [
      "88",
      "129"
    ],
    [
      "88",
      "133"
    ],
    [
      "88",
      "131"
    ],
    [
      "88",
      "135"
    ],
    [
      "88",
      "129"
    ],
    [
      "88",
      "133"
    ],
    [
      "88",
      "131"
    ],
    [
      "88",
      "135"
    ],
    [
      "89",
      "90"
    ],
    [
      "90",
      "143"
    ],
    [
      "90",
      "141"
    ],
    [
      "90",
      "145"
    ],
    [
      "90",
      "147"
    ],
    [
      "90",
      "143"
    ],
    [
      "90",
      "141"
    ],
    [
      "90",
      "145"
    ],
    [
      "90",
      "147"
    ],
    [
      "91",
      "92"
    ],
    [
      "92",
      "143"
    ],
    [
      "92",
      "143"
    ],
    [
      "92",
      "145"
    ],
    [
      "92",
      "145"
    ],
    [
      "93",
      "94"
    ],
    [
      "94",
      "121"
    ],
    [
      "94",
      "123"
    ],
    [
      "94",
      "125"
    ],
    [
      "94",
      "127"
    ],
    [
      "94",
      "121"
    ],
    [
      "94",
      "123"
    ],
    [
      "94",
      "125"
    ],
    [
      "94",
      "127"
    ],
    [
      "95",
      "96"
    ],
    [
      "96",
      "121"
    ],
    [
      "96",
      "121"
    ],
    [
      "96",
      "125"
    ],
    [
      "96",
      "125"
    ],
    [
      "97",
      "98"
    ],
    [
      "98",
      "149"
    ],
    [
      "98",
      "149"
    ],
    [
      "98",
      "151"
    ],
    [
      "98",
      "151"
    ],
    [
      "98",
      "153"
    ],
    [
      "98",
      "153"
    ],
    [
      "98",
      "155"
    ],
    [
      "98",
      "155"
    ],
    [
      "98",
      "108"
    ],
    [
      "98",
      "112"
    ],
    [
      "99",
      "100"
    ],
    [
      "100",
      "149"
    ],
    [
      "100",
      "149"
    ],
    [
      "100",
      "153"
    ],
    [
      "100",
      "153"
    ],
    [
      "100",
      "106"
    ],
    [
      "101",
      "102"
    ],
    [
      "102",
      "157"
    ],
    [
      "102",
      "157"
    ],
    [
      "102",
      "159"
    ],
    [
      "102",
      "159"
    ],
    [
      "102",
      "161"
    ],
    [
      "102",
      "161"
    ],
    [
      "102",
      "163"
    ],
    [
      "102",
      "163"
    ],
    [
      "102",
      "118"
    ],
    [
      "103",
      "104"
    ],
    [
      "104",
      "157"
    ],
    [
      "104",
      "157"
    ],
    [
      "104",
      "159"
    ],
    [
      "104",
      "159"
    ],
    [
      "105",
      "106"
    ],
    [
      "106",
      "149"
    ],
    [
      "106",
      "153"
    ],
    [
      "106",
      "149"
    ],
    [
      "106",
      "153"
    ],
    [
      "107",
      "108"
    ],
    [
      "108",
      "149"
    ],
    [
      "108",
      "151"
    ],
    [
      "108",
      "153"
    ],
    [
      "108",
      "155"
    ],
    [
      "108",
      "149"
    ],
    [
      "108",
      "151"
    ],
    [
      "108",
      "153"
    ],
    [
      "108",
      "155"
    ],
    [
      "108",
      "112"
    ],
    [
      "109",
      "110"
    ],
    [
      "110",
      "165"
    ],
    [
      "110",
      "165"
    ],
    [
      "110",
      "167"
    ],
    [
      "110",
      "167"
    ],
    [
      "110",
      "114"
    ],
    [
      "111",
      "112"
    ],
    [
      "112",
      "149"
    ],
    [
      "112",
      "151"
    ],
    [
      "112",
      "153"
    ],
    [
      "112",
      "155"
    ],
    [
      "112",
      "149"
    ],
    [
      "112",
      "151"
    ],
    [
      "112",
      "153"
    ],
    [
      "112",
      "155"
    ],
    [
      "113",
      "114"
    ],
    [
      "114",
      "165"
    ],
    [
      "114",
      "167"
    ],
    [
      "114",
      "165"
    ],
    [
      "114",
      "167"
    ],
    [
      "115",
      "116"
    ],
    [
      "116",
      "167"
    ],
    [
      "116",
      "167"
    ],
    [
      "117",
      "118"
    ],
    [
      "118",
      "157"
    ],
    [
      "118",
      "159"
    ],
    [
      "118",
      "161"
    ],
    [
      "118",
      "163"
    ],
    [
      "118",
      "157"
    ],
    [
      "118",
      "159"
    ],
    [
      "118",
      "161"
    ],
    [
      "118",
      "163"
    ],
    [
      "119",
      "120"
    ],
    [
      "120",
      "161"
    ],
    [
      "120",
      "161"
    ],
    [
      "120",
      "157"
    ],
    [
      "120",
      "157"
    ],
    [
      "121",
      "122"
    ],
    [
      "122",
      "169"
    ],
    [
      "122",
      "169"
    ],
    [
      "122",
      "171"
    ],
    [
      "122",
      "171"
    ],
    [
      "122",
      "154"
    ],
    [
      "123",
      "124"
    ],
    [
      "124",
      "169"
    ],
    [
      "124",
      "169"
    ],
    [
      "124",
      "173"
    ],
    [
      "124",
      "173"
    ],
    [
      "124",
      "132"
    ],
    [
      "125",
      "126"
    ],
    [
      "126",
      "169"
    ],
    [
      "126",
      "169"
    ],
    [
      "127",
      "128"
    ],
    [
      "128",
      "171"
    ],
    [
      "128",
      "171"
    ],
    [
      "128",
      "175"
    ],
    [
      "128",
      "175"
    ],
    [
      "128",
      "173"
    ],
    [
      "128",
      "173"
    ],
    [
      "128",
      "169"
    ],
    [
      "128",
      "169"
    ],
    [
      "128",
      "136"
    ],
    [
      "128",
      "156"
    ],
    [
      "129",
      "130"
    ],
    [
      "130",
      "177"
    ],
    [
      "130",
      "177"
    ],
    [
      "130",
      "179"
    ],
    [
      "130",
      "179"
    ],
    [
      "130",
      "146"
    ],
    [
      "131",
      "132"
    ],
    [
      "132",
      "169"
    ],
    [
      "132",
      "173"
    ],
    [
      "132",
      "169"
    ],
    [
      "132",
      "173"
    ],
    [
      "133",
      "134"
    ],
    [
      "134",
      "181"
    ],
    [
      "134",
      "181"
    ],
    [
      "134",
      "183"
    ],
    [
      "134",
      "183"
    ],
    [
      "134",
      "177"
    ],
    [
      "134",
      "177"
    ],
    [
      "134",
      "179"
    ],
    [
      "134",
      "179"
    ],
    [
      "134",
      "140"
    ],
    [
      "134",
      "148"
    ],
    [
      "135",
      "136"
    ],
    [
      "136",
      "171"
    ],
    [
      "136",
      "175"
    ],
    [
      "136",
      "173"
    ],
    [
      "136",
      "169"
    ],
    [
      "136",
      "171"
    ],
    [
      "136",
      "175"
    ],
    [
      "136",
      "173"
    ],
    [
      "136",
      "169"
    ],
    [
      "136",
      "156"
    ],
    [
      "137",
      "138"
    ],
    [
      "138",
      "179"
    ],
    [
      "138",
      "179"
    ],
    [
      "138",
      "181"
    ],
    [
      "138",
      "181"
    ],
    [
      "138",
      "142"
    ],
    [
      "139",
      "140"
    ],
    [
      "140",
      "181"
    ],
    [
      "140",
      "183"
    ],
    [
      "140",
      "177"
    ],
    [
      "140",
      "179"
    ],
    [
      "140",
      "181"
    ],
    [
      "140",
      "183"
    ],
    [
      "140",
      "177"
    ],
    [
      "140",
      "179"
    ],
    [
      "140",
      "148"
    ],
    [
      "141",
      "142"
    ],
    [
      "142",
      "179"
    ],
    [
      "142",
      "181"
    ],
    [
      "142",
      "179"
    ],
    [
      "142",
      "181"
    ],
    [
      "143",
      "144"
    ],
    [
      "144",
      "179"
    ],
    [
      "144",
      "179"
    ],
    [
      "145",
      "146"
    ],
    [
      "146",
      "177"
    ],
    [
      "146",
      "179"
    ],
    [
      "146",
      "177"
    ],
    [
      "146",
      "179"
    ],
    [
      "147",
      "148"
    ],
    [
      "148",
      "181"
    ],
    [
      "148",
      "183"
    ],
    [
      "148",
      "177"
    ],
    [
      "148",
      "179"
    ],
    [
      "148",
      "181"
    ],
    [
      "148",
      "183"
    ],
    [
      "148",
      "177"
    ],
    [
      "148",
      "179"
    ],
    [
      "149",
      "150"
    ],
    [
      "150",
      "185"
    ],
    [
      "150",
      "185"
    ],
    [
      "150",
      "187"
    ],
    [
      "150",
      "187"
    ],
    [
      "150",
      "160"
    ],
    [
      "151",
      "152"
    ],
    [
      "152",
      "187"
    ],
    [
      "152",
      "187"
    ],
    [
      "152",
      "189"
    ],
    [
      "152",
      "189"
    ],
    [
      "152",
      "185"
    ],
    [
      "152",
      "185"
    ],
    [
      "152",
      "191"
    ],
    [
      "152",
      "191"
    ],
    [
      "152",
      "164"
    ],
    [
      "152",
      "166"
    ],
    [
      "153",
      "154"
    ],
    [
      "154",
      "169"
    ],
    [
      "154",
      "171"
    ],
    [
      "154",
      "169"
    ],
    [
      "154",
      "171"
    ],
    [
      "155",
      "156"
    ],
    [
      "156",
      "171"
    ],
    [
      "156",
      "175"
    ],
    [
      "156",
      "173"
    ],
    [
      "156",
      "169"
    ],
    [
      "156",
      "171"
    ],
    [
      "156",
      "175"
    ],
    [
      "156",
      "173"
    ],
    [
      "156",
      "169"
    ],
    [
      "157",
      "158"
    ],
    [
      "158",
      "185"
    ],
    [
      "158",
      "185"
    ],
    [
      "159",
      "160"
    ],
    [
      "160",
      "185"
    ],
    [
      "160",
      "187"
    ],
    [
      "160",
      "185"
    ],
    [
      "160",
      "187"
    ],
    [
      "161",
      "162"
    ],
    [
      "162",
      "185"
    ],
    [
      "162",
      "185"
    ],
    [
      "162",
      "191"
    ],
    [
      "162",
      "191"
    ],
    [
      "162",
      "168"
    ],
    [
      "163",
      "164"
    ],
    [
      "164",
      "187"
    ],
    [
      "164",
      "189"
    ],
    [
      "164",
      "185"
    ],
    [
      "164",
      "191"
    ],
    [
      "164",
      "187"
    ],
    [
      "164",
      "189"
    ],
    [
      "164",
      "185"
    ],
    [
      "164",
      "191"
    ],
    [
      "164",
      "166"
    ],
    [
      "165",
      "166"
    ],
    [
      "166",
      "187"
    ],
    [
      "166",
      "189"
    ],
    [
      "166",
      "185"
    ],
    [
      "166",
      "191"
    ],
    [
      "166",
      "187"
    ],
    [
      "166",
      "189"
    ],
    [
      "166",
      "185"
    ],
    [
      "166",
      "191"
    ],
    [
      "167",
      "168"
    ],
    [
      "168",
      "185"
    ],
    [
      "168",
      "191"
    ],
    [
      "168",
      "185"
    ],
    [
      "168",
      "191"
    ],
    [
      "169",
      "170"
    ],
    [
      "171",
      "172"
    ],
    [
      "172",
      "188"
    ],
    [
      "173",
      "174"
    ],
    [
      "174",
      "178"
    ],
    [
      "175",
      "176"
    ],
    [
      "176",
      "184"
    ],
    [
      "176",
      "190"
    ],
    [
      "177",
      "178"
    ],
    [
      "179",
      "180"
    ],
    [
      "181",
      "182"
    ],
    [
      "182",
      "192"
    ],
    [
      "183",
      "184"
    ],
    [
      "184",
      "190"
    ],
    [
      "185",
      "186"
    ],
    [
      "187",
      "188"
    ],
    [
      "189",
      "190"
    ],
    [
      "191",
      "192"
    ],
    [
      "193",
      "194"
    ],
    [
      "194",
      "57"
    ],
    [
      "194",
      "59"
    ],
    [
      "194",
      "61"
    ],
    [
      "194",
      "63"
    ],
    [
      "194",
      "57"
    ],
    [
      "194",
      "59"
    ],
    [
      "194",
      "61"
    ],
    [
      "194",
      "63"
    ],
    [
      "195",
      "196"
    ],
    [
      "196",
      "59"
    ],
    [
      "196",
      "59"
    ],
    [
      "196",
      "61"
    ],
    [
      "196",
      "61"
    ],
    [
      "197",
      "198"
    ],
    [
      "198",
      "91"
    ],
    [
      "198",
      "91"
    ],
    [
      "198",
      "85"
    ],
    [
      "198",
      "85"
    ],
    [
      "199",
      "200"
    ],
    [
      "200",
      "85"
    ],
    [
      "200",
      "87"
    ],
    [
      "200",
      "89"
    ],
    [
      "200",
      "91"
    ],
    [
      "200",
      "85"
    ],
    [
      "200",
      "87"
    ],
    [
      "200",
      "89"
    ],
    [
      "200",
      "91"
    ],
    [
      "201",
      "202"
    ],
    [
      "202",
      "203"
    ],
    [
      "202",
      "203"
    ],
    [
      "202",
      "11"
    ],
    [
      "202",
      "11"
    ],
    [
      "202",
      "15"
    ],
    [
      "202",
      "15"
    ],
    [
      "203",
      "204"
    ],
    [
      "204",
      "193"
    ],
    [
      "204",
      "193"
    ],
    [
      "204",
      "195"
    ],
    [
      "204",
      "195"
    ],
    [
      "204",
      "197"
    ],
    [
      "204",
      "197"
    ],
    [
      "204",
      "199"
    ],
    [
      "204",
      "199"
    ]
  ]
}
#endif //TRACE_JSON

#if LOCKS_JSON
{"no_timing": {"spin_states": {"S1": 12, "S2": 0}}}
#endif //LOCKS_JSON





DeclareTask(T01);
DeclareTask(T11);
DeclareTask(T21);
DeclareSpinlock(S1);
DeclareSpinlock(S2);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T01) {
	ActivateTask(T11);
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T11) {
	ActivateTask(T21);
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T21) {
	GetSpinlock(S2);
	ReleaseSpinlock(S2);
	TerminateTask();
}

