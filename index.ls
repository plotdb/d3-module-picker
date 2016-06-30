angular.module \d3-module-picker, <[]>
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
  ..controller \d3-module-picker, <[$scope]> ++ ($scope) ->
    $scope.output = {}
    $scope.$watch 'modules', (list) -> 
      if !list => return
      list = list.map -> it.split \/
      urls = list.map -> "https://d3js.org/d3-#{it.0}-#{it.1}.js"
      $scope.output.html = urls.map(-> "<script src=\"#it\"></script>").join(\\n)
      $scope.output.jade = urls.map(-> "script(src=\"#it\")").join(\\n)
      $scope.output.npm = "npm install " + list.map(->"#{it.0}@#{it.1}").join(' ')
