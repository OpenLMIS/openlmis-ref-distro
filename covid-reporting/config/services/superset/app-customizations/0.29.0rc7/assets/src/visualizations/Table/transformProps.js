export default function transformProps(chartProps) {
  const {
    height,
    datasource,
    filters,
    formData,
    onAddFilter,
    payload
  } = chartProps;
  const {
    alignPn,
    colorPn,
    includeSearch,
    metrics,
    orderDesc,
    pageLength,
    percentMetrics,
    tableFilter,
    tableTimestampFormat,
    timeseriesLimitMetric,
    sliceId
  } = formData;
  const { columnFormats, verboseMap } = datasource;
  const { records, columns } = payload.data;

  const processedColumns = columns.map((key) => {
    let label = verboseMap[key];
    // Handle verbose names for percents
    if (!label) {
      if (key[0] === '%') {
        const cleanedKey = key.substring(1);
        label = '% ' + (verboseMap[cleanedKey] || cleanedKey);
      } else {
        label = key;
      }
    }
    return {
      key,
      label,
      format: columnFormats && columnFormats[key],
    };
  });

  var reportName;
  var locationParts = window.location.href.split('/');
  for (var i = 0; i < locationParts.length; i++) {
    if (locationParts[i] === "dashboard") {
      reportName = locationParts[i + 1];
    }
  }

  const tableIdentifier = reportName + '-DataTable-' + formData.sliceId;
  return {
    height,
    data: records,
    alignPositiveNegative: alignPn,
    colorPositiveNegative: colorPn,
    columns: processedColumns,
    filters,
    includeSearch,
    metrics,
    onAddFilter,
    orderDesc,
    pageLength: pageLength && parseInt(pageLength, 10),
    percentMetrics,
    tableFilter,
    tableTimestampFormat,
    timeseriesLimitMetric,
    tableIdentifier
  };
}
