import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';

const appReducer = combineReducers({
  form,
});

export default function (state, action) {
  return appReducer(state, action);
}
