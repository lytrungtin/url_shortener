import api from '../api';

export function encodeUrl(data) {
  return dispatch => api.post('/url/encode', data)
    .then((response) => {
      dispatch({ type: 'ENCODE_URL_SUCCESS', response });
      alert(response.data[0].shortened_url);
    })
    .catch((error) => {
      dispatch({ type: 'ENCODE_URL_FAILURE', error });
    });
}

export function decodeUrl(data) {
  return dispatch => api.post('/url/decode', data)
    .then((response) => {
      dispatch({ type: 'DECODE_URL_SUCCESS', response });
      alert(response.data[0].original_url);
    })
    .catch((error) => {
      dispatch({ type: 'DECODE_URL_FAILURE', error });
    });
}
