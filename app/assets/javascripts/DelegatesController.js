angular.module('delegatesApp', ['ui.select'])
.config(function(uiSelectConfig) {
  uiSelectConfig.theme = 'bootstrap';
})
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
    },
    delete: function(delegate) {
      var url, method;
      url = "/delegation/delegates/" + delegate.id + ".json";
      method = 'DELETE';
      return $http({
        method: method,
        url: url,
        data: {
          authenticity_token: RailsService.getAuthenticityToken()
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
    if (seats) {
      return $.grep(seats, function(seat) {
        return (!seat.delegate_id || seat.delegate_id == delegate.id);
      });
    } else {
      return [];
    }
  };
})
.controller('DelegatesController', function($scope, $http, $q, DelegatesService, SeatsService) {
  $scope.delegates = [];
  $scope.seats = [];
  $scope.loaded = false;
  $scope.forms = {};
  $http.get('/delegation/delegates.json')
  .success(function(data, status, headers, config) {
    $scope.delegates = data;
    $scope.loaded = true;
  })
  .error(function(data, status, headers, config) {

  });
  $http.get('/delegation/seats.json')
  .success(function(data, status, headers, config) {
    $scope.seats = data;
    $scope.committees = [];
    $.each($scope.seats, function(i, seat) {
      if (seat.delegate_id) {
        for (var j=0; j<$scope.delegates.length; j++) {
          if ($scope.delegates[j].id == seat.delegate_id) {
            $scope.delegates[j].committee = seat.committees[0];
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
        if (delegate.seat && !delegate.seat.unsaved) {
          $scope.saveSeat(delegate.seat, delegate, form);
        }
      })
      .error(function(data, status, headers, config) {
        delegate.saving = false;
        if (data.errors) {
          delegate.error = $.map(data.errors, function(value, key) {
            return key.capitalize() + ' ' + value;
          }).join(', ') + '.';
        }
      });
    } else if (form.$dirty && delegate.id && delegate.first_name == delegate.last_name == delegate.email == '') {
      // delete this delegate
      DelegatesService.delete(delegate)
      .success(function(data, status, headers, config) {
        delegate.id = null;
        form.$dirty = false;
        delegate.error = "";
      })
      .error(function(data, status, headers, config) {
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
        if (oldSeat) {
          oldSeat.delegate_id = null;
          oldSeat.saved = false;
        }
        if (seat) {
          seat.delegate_id = delegate.id;
          seat.saved = true;
        }
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
      if (delegate.form) {
        if (delegate.form.$dirty || !delegate.id) {
          unsavedDelegates++;
        } else {
          savedDelegates++;
        }
      }
    });
    return savedDelegates + " delegate" + (savedDelegates == 1 ? '' : 's') + " saved, "
      + unsavedDelegates + " delegate" + (unsavedDelegates == 1 ? '' : 's') + " unsaved."
  };
  $scope.committeeText = function(seat) {
    return $.map(seat.committees, function(committee) {
      return committee.name;
    }).join('; ')
  };
});
