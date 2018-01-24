(function() {

  var w = angular.module('aquarium');

  w.controller('technicianCtrl', [ '$scope', '$http', '$attrs', '$cookies', '$sce',
                        function (  $scope,   $http,   $attrs,   $cookies,   $sce ) {

    AQ.init($http);
    AQ.update = () => { $scope.$apply(); }
    AQ.confirm = (msg) => { return confirm(msg); }

    let job_id = parseInt(aq.url_path()[2]);

    $scope.job_id = job_id;
    $scope.uploads = {}; 
    $scope.selects = [];
    $scope.item = null;


    AQ.Job.find(job_id).then(job => {

      $scope.job = job;

      AQ.Job.active_jobs().then(job_ids => {
        console.log("Active Jobs", job_ids);
        if ( job_ids.indexOf($scope.job_id) == -1 && !job.backtrace.complete ) {
          $scope.zombie = true;
        }
        $scope.$apply();
      })      

    }).catch(job => {
      $scope.not_found = true;
      $scope.$apply();
    })

    $scope.content_type = function(line) {
      var type = Object.keys(line)[0];
      return type;
    };

    $scope.table_input = function(cell,response) {
      let x = aq.where(response.inputs.table_inputs, input => input.opid == cell.operation_id && input.key == cell.key)[0];
      if ( x ) {
        return x.value;
      } else {
        return null;
      }
    }

    $scope.content_value = function(line) {
      var k = Object.keys(line)[0];
      if ( typeof line[k] === "string" ) {
        let html = $sce.trustAsHtml(line[k]);
        return html;
      } else {
        return line[k];
      }
    }

    $scope.sce = function(data) {

      if ( typeof data== "string" ) {
        return $sce.trustAsHtml(data);
      } else {
        return $sce.trustAsHtml(JSON.stringify(data));;
      }
    }

    $scope.check = function(cell) {
      if ( cell.check ) {
        cell.checked = !cell.checked;
      }
    }

    $scope.table_class = function(cell,step) {
      var c = "no-highlight";
      if ( cell == null ) {
        c += " td-null-cell";
      } else if ( cell.class ) {
        c += " " + cell.class;
      }
      if ( cell && cell.check && ( cell.checked || !step.response.in_progress ) ) {
        c += " td-checked";
      }
      if ( cell && cell.check && !cell.checked && step.response.in_progress ) {
        c += " td-notchecked";
      }
      if ( cell && cell.type ) {
        c += " td-input"
      }
      return c;
    };

    $scope.keyDown = function(evt) {

      switch(evt.key) {

        case "ArrowLeft":
        case "ArrowUp":
          if ( $scope.job.state.index > 0 ) {
            $scope.job.state.index--;
          }
          break;
        case "ArrowRight":
        case "ArrowDown":
          if ( $scope.job.state.index < $scope.job.backtrace.length - 1 ) {
            $scope.job.state.index++;
          }
          break;

        default:

      }

    }

    $scope.start_upload = function(varname) {

      $("#upload-"+varname).click();
      $scope.upload_varname = varname;      

    }

    function send_file(file) {

      var r = new FileReader();

      file.status = "loading";
      file.percent = 0;

      if ( ! $scope.uploads[$scope.upload_varname] ) {
        $scope.uploads[$scope.upload_varname] = [];
      }

      $scope.uploads[$scope.upload_varname].push(file);

      $scope.$apply();

      r.onprogress = function(e) {
        file.progress = e;
        $scope.$apply();
      }

      r.onload = function(e) {

        var data = e.target.result;
        var fd = new FormData();
        var uri = "/krill/upload";
        var xhr = new XMLHttpRequest();

        file.status = "sending";
        $scope.$apply();
        
        xhr.open("POST", uri, true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                var upload = AQ.Upload.record(JSON.parse(xhr.responseText));
                $scope.job.uploads.push(upload)
                file.status = "complete";
                $scope.$apply();
            }
        };

        fd.append('file', file)
        fd.append('authenticity_token', $("#authenticity_token").val());
        fd.append('job', $scope.job.id)
        xhr.send(fd);          

      }

      r.readAsBinaryString(file);         

    }

    $scope.complete_upload = function(files) {

      for ( var i=0; i<files.length; i++ ) {      
        send_file(files[i])
      }

    }

    $scope.ok = function() {
      $scope.job.advance().then(() => {
        $scope.job.recompute_getter("operations")
      })
    }

    $scope.pretty = function(loc) {
      return loc.replace("(eval)", "Protocol")
    }

    $scope.open_item_ui = function(id) {
      AQ.Item.where({id: id}, { include: ["object_type", "sample"]}).then(items => {
        if ( items.length > 0 ) {
          $scope.item = items[0];
          $scope.item.modal = true;
          $scope.$apply();
        } else {
          alert("Item " + id + " not found.")
        }
      });
    }

    $scope.cancel = function() {
      if ( confirm("Are you sure you want to cancel this job?") ) {
        $scope.job.abort().then(response => {
          AQ.Job.find($scope.job_id).then(job => {            
            $scope.job = job;  
            $scope.zombie = false;
            $scope.$apply();
          })
        })
      }
    }

  }]);

})();















