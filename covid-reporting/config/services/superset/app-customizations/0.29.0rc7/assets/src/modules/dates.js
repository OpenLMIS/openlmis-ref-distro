import d3 from 'd3';
import moment from 'moment';
import * as d3TimeFormat from 'd3-time-format'
import localStorage from 'local-storage'

const D3_LOCALES_MAP = {
  en: require('d3-time-format/locale/en-GB.json'),
  pt: require('d3-time-format/locale/pt-BR.json')
}
const DEFAULT_D3_LANGUAGE = D3_LOCALES_MAP.en;

function getTimeFormatLocale() {
  const currentLocale = localStorage.get('locale');
  const localeDefinition = D3_LOCALES_MAP[currentLocale] ? D3_LOCALES_MAP[currentLocale] : DEFAULT_D3_LANGUAGE;
  return d3TimeFormat.timeFormatDefaultLocale(localeDefinition)
}
const localizedD3Time = getTimeFormatLocale();

export function UTC(dttm) {
  return new Date(
    dttm.getUTCFullYear(),
    dttm.getUTCMonth(),
    dttm.getUTCDate(),
    dttm.getUTCHours(),
    dttm.getUTCMinutes(),
    dttm.getUTCSeconds(),
  );
}

export const tickMultiFormat = (() => {
  const formatMillisecond = localizedD3Time.format('.%Lms');
  const formatSecond = localizedD3Time.format(':%Ss');
  const formatMinute = localizedD3Time.format('%I:%M');
  const formatHour = localizedD3Time.format('%I %p');
  const formatDay = localizedD3Time.format('%a %d');
  const formatWeek = localizedD3Time.format('%b %d');
  const formatMonth = localizedD3Time.format('%B');
  const formatYear = localizedD3Time.format('%Y');

  return function tickMultiFormatConcise(date) {
    let formatter;
    if (d3.time.second(date) < date) {
      formatter = formatMillisecond;
    } else if (d3.time.minute(date) < date) {
      formatter = formatSecond;
    } else if (d3.time.hour(date) < date) {
      formatter = formatMinute;
    } else if (d3.time.day(date) < date) {
      formatter = formatHour;
    } else if (d3.time.month(date) < date) {
      formatter = d3.time.week(date) < date ? formatDay : formatWeek;
    } else if (d3.time.year(date) < date) {
      formatter = formatMonth;
    } else {
      formatter = formatYear;
    }

    return formatter(date);
  };
})();


export function tickMultiFormatVerbose(d) {
  let formatter;
  if (d.getMilliseconds()) {
    // If there are millisections, show  only them
    formatter = localizedD3Time.format('.%L');
  } else if (d.getSeconds()) {
    // If there are seconds, show only them
    formatter = localizedD3Time.format(':%S');
  } else if (d.getMinutes() !== 0) {
    // If there are non-zero minutes, show Date, Hour:Minute [AM/PM]
    formatter = localizedD3Time.format('%a %b %d, %I:%M %p');
  } else if (d.getHours() !== 0) {
    // If there are hours that are multiples of 3, show date and AM/PM
    formatter = localizedD3Time.format('%a %b %d, %I %p');
  } else if (d.getDate() >= 10) {
    // If not the first of the month: "Tue Mar 2"
    formatter = localizedD3Time.format('%a %b %e');
  } else if (d.getDate() > 1) {
    formatter = localizedD3Time.format('%a %b%e');
    // If >= 10th of the month, compensate for padding : "Sun Mar 15"
  } else if (d.getMonth() !== 0 && d.getDate() === 1) {
    // If the first of the month: 'Mar 2020'
    formatter = localizedD3Time.format('%b %Y');
  } else {
    // fall back on just year: '2020'
    formatter = localizedD3Time.format('%Y');
  }

  return formatter(d);
}

export const formatDate = function (dttm) {
  const d = UTC(new Date(dttm));
  return tickMultiFormat(d);
};

export const formatDateVerbose = function (dttm) {
  const d = UTC(new Date(dttm));
  return tickMultiFormatVerbose(d);
};

export const formatDateThunk = function (format) {
  if (!format) {
    return formatDateVerbose;
  }

  const formatter = localizedD3Time.format(format);
  return (dttm) => {
    const d = UTC(new Date(dttm));
    return formatter(d);
  };
};

export const fDuration = function (t1, t2, format = 'HH:mm:ss.SS') {
  const diffSec = t2 - t1;
  const duration = moment(new Date(diffSec));
  return duration.utc().format(format);
};

export const now = function () {
  // seconds from EPOCH as a float
  return moment().utc().valueOf();
};

export const epochTimeXHoursAgo = function (h) {
  return moment()
    .subtract(h, 'hours')
    .utc()
    .valueOf();
};

export const epochTimeXDaysAgo = function (d) {
  return moment()
    .subtract(d, 'days')
    .utc()
    .valueOf();
};

export const epochTimeXYearsAgo = function (y) {
  return moment()
    .subtract(y, 'years')
    .utc()
    .valueOf();
};
