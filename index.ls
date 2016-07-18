angular.module \d3-module-picker, <[]>
  ..config <[$compileProvider]> ++ ($compileProvider) ->
    $compileProvider.aHrefSanitizationWhitelist(/^\s*blob:/)
  ..directive \ngselect2, -> do
    require: <[]>
    restrict: \A
    scope: do
      model: \=ngData
      istag: \@istag
    link: (s,e,a,c) ->
      changed = ->
        [cval,nval] = [s.model, $(e).val!]
        if !Array.isArray(cval) => return cval != nval
        [cval,nval] = [cval,nval].map -> (it or []).join(",")
        cval != nval
      config = {}
      if s.istag => config <<< tags: true, tokenSeparators: [',',' ']
      $(e).select2 config
      $(e).select2 config .on \change, ~>
        # angularjs create object for chart if s.model = chart.blah and chart = undefined.
        # be aware of this behavior
        if changed! => setTimeout (-> s.$apply -> s.model = $(e)val!),0
      s.$watch 'model', (vals) ~>
        # escaped html from jquery.
        # jquery.val won't help select2 build option tags so we have to do this by ourselves
        if config.tags =>
          html = ""
          for val in (vals or []) => html += $("<option></option>").val(val).text(val).0.outerHTML
          $(e).html(html)
        if changed! => setTimeout (-> $(e).val(vals).trigger(\change) ),0
  ..controller \d3-module-picker, <[$scope $http]> ++ ($scope, $http) ->
    $scope.output = {}
    $scope.urls = []
    $scope.bundleURL = ""
    $scope.$watch 'modules', (list) -> 
      if !list => return
      list = list.map -> it.split \/
      urls = $scope.urls = list.map -> "https://d3js.org/#{it.0}.v#{it.1}.js"
      $scope.output.html = urls.map(-> "<script src=\"#it\"></script>").join(\\n)
      $scope.output.jade = urls.map(-> "script(src=\"#it\")").join(\\n)
      $scope.output.npm = "npm install " + list.map(->"#{it.0}@#{it.1}").join(' ')
    $scope.fetch = (url) -> new Promise (res, rej) ->
      $http { url: url, method: \GET }
        .success (d) -> res d
        .error (d) -> rej!
    $scope.loading = false
    $scope.make-bundle = ->
      $scope.loading = true
      promises = $scope.urls.map -> $scope.fetch it
      Promise.all promises
        .then (data) -> $scope.$apply ->
          $scope.bundleURL = URL.createObjectURL new Blob [data.join(\\n)], {type: \text/javascript}
          $scope.loading = false
