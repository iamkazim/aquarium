(function() {

  var w = angular.module('aquarium');

  w.directive("oplist", ['$mdDialog', function($mdDialog) {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list').html(),
      link: function($scope) {
        $scope.change_status = function(operation, status) {

          let confirm = $mdDialog.confirm()
              .title('Change Operation Status:')
              .textContent(`Do you really want to change the status of operation ${operation.id} to ${status}?`)
              .ariaLabel('Change Status')
              .ok('Yes')
              .cancel('No');

          $mdDialog.show(confirm).then(() => {
            operation.set_status(status);
            window.location = '/operations'
          });

        }
      }
    }

  }]);

  w.directive("oplistShort", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=', brief: '=' },
      replace: true,
      template: $('#operation-list-short').html(),
      link: function($scope,$element,$attributes) {
        $scope.open_item_ui = function(id) {
          open_item_ui(id);
        }
      }
    }

  });

  w.directive("oplistReport", function() {

    return {
      restrict: 'E',
      scope: { operations: '=', status: '=', operationtype: '=', jobid: '=' },
      replace: true,
      template: $('#operation-list-report').html()
    }

  });

  w.filter('naturalDate', function(){
    return function(date){

      // ACTUAL TIMESTAMP
      var today = new Date()

      // TIMESTAMP FOR INPUT DATE AT 00:00:00
      date = new Date(date)
      date_begin = new Date( date.getFullYear(), date.getMonth() , date.getDate())

      // GET DAYS (0 = TODAY)
      var days = Math.floor((today - date_begin)/86400000)

      switch(true) {
        case (days == 0):
          return "Today"
          break;
        case (days == 1):
          return "Yesterday"
          break;
        case (days > 1 && days < 8):
          return days + " days ago"
          break;
        default:
          // TODO: DECLARE THIS A CONSTANT
          var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
          return months[date.getMonth()]+" "+date.getDate()+", "+date.getFullYear()
      }
    }
  });
})();

