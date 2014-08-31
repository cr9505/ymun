angular.module('delegatesApp', [])
.factory('RailsService', function() {
  return {
    getAuthenticityToken: function() {
      return angular.element('meta[name=csrf-token]').attr('content');
    }
  }
})
.factory('DelegatesService', function($http, RailsService) {
  return {
    createOrUpdate: function(delegate) {
      var url, method;
      if (delegate.id) {
        url = "/delegation/delegates/" + delegate.id + ".json";
        method = 'PUT'
      } else {
        url = "/delegation/delegates.json";
        method = 'POST'
      }
      return $http({
        method: method,
        url: url,
        data: {
          authenticity_token: RailsService.getAuthenticityToken(),
          delegate: {
            first_name: delegate.first_name, 
            last_name: delegate.last_name,
            email: delegate.email
          }
        }
      });
    }
  }
})
.controller('DelegatesController', function($scope, $http, DelegatesService) {
  $scope.delegates = [];
  $scope.forms = {};
  $http.get('/delegation/delegates.json')
  .success(function(data, status, headers, config) {
    $scope.delegates = data;
  })
  .error(function(data, status, headers, config) {

  });
  $scope.saveDelegate = function(delegate, form) {
    if (form.$valid && form.$dirty) {
      delegate.saving = true;
      DelegatesService.createOrUpdate(delegate)
      .success(function(data, status, headers, config) {
        delegate.saving = false;
        form.$dirty = false;
        if (data) delegate.id = data.id;
      })
      .error(function(data, status, headers, config) {
        delegate.saving = false;
        if (data.errors) {
          delegate.error = $.map(data.errors, function(value, key) {
            return key.capitalize() + ' ' + value;
          }).join(', ') + '.';
        }
      });
    }
  };
});