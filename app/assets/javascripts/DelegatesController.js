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
.factory('SeatsService', function($http, RailsService) {
  return {
    assign: function(seat, delegate) {
      var delegate_id = null;
      if (delegate) delegate_id = delegate.id;
      var url, method;
      url = "/delegation/seats/" + seat.id + ".json";
      method = 'PUT';
      return $http({
        method: method,
        url: url,
        data: {
          authenticity_token: RailsService.getAuthenticityToken(),
          seat: {
            delegate_id: delegate_id
          }
        }
      });
    }
  }
})
.filter('unclaimedFor', function() {
  return function(seats, delegate) {
    return $.grep(seats, function(seat) {
      return (!seat.delegate_id || seat.delegate_id == delegate.id);
    })
  };
})
.controller('DelegatesController', function($scope, $http, $q, DelegatesService, SeatsService) {
  $scope.delegates = [];
  $scope.seats = [];
  $scope.forms = {};
  $http.get('/delegation/delegates.json')
  .success(function(data, status, headers, config) {
    $scope.delegates = data;
  })
  .error(function(data, status, headers, config) {

  });
  $http.get('/delegation/seats.json')
  .success(function(data, status, headers, config) {
    $scope.seats = data;
    $.each($scope.seats, function(i, seat) {
      if (seat.delegate_id) {
        for (var j=0; j<$scope.delegates.length; j++) {
          if ($scope.delegates[j].id == seat.delegate_id) {
            $scope.delegates[j].seat = seat;
            break;
          }
        }
      }
    })
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
        delegate.error = "";
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
  $scope.saveSeat = function(seat, delegate, form) {
    console.log("Firing " + form.$dirty);
    if (form.$valid && delegate.id) {
      delegate.saving = true;
      oldSeat = delegate.oldSeat;
      var promises = [];
      console.log(oldSeat);
      console.log(seat);
      if (oldSeat) {
        promises.push(SeatsService.assign(oldSeat, null));
      }
      if (seat) {
        promises.push(SeatsService.assign(seat, delegate));
      }
      $q.all(promises)
      .then(function(values) {
        delegate.saving = false;
        form.$dirty = false;
        delegate.error = "";
        if (oldSeat) oldSeat.delegate_id = null;
        if (seat) seat.delegate_id = delegate.id;
      },
      function(errors) {
        delegate.saving = false;
        form.$dirty = false;
        delegate.error = 'Could not save seat selection. Please refresh the page and try again.';
      });
    }
  };
  $scope.saveStatus = function(delegates) {
    var savedDelegates = 0;
    var unsavedDelegates = 0;
    $.each(delegates, function(i, delegate) {
      if (delegate.saving) {
        return "Saving...";
      }
      if (delegate.form.$dirty || !delegate.id) {
        unsavedDelegates++;
      } else {
        savedDelegates++;
      }
    });
    return savedDelegates + " delegate" + (savedDelegates == 1 ? '' : 's') + " saved, "
      + unsavedDelegates + " delegate" + (unsavedDelegates == 1 ? '' : 's') + " unsaved."
  }
});
