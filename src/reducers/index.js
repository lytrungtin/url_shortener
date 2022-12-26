import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';
import urls from './urls';

const appReducer = combineReducers({
  form,
  urls
});

export default function (state, action) {
  return appReducer(state, action);
}
