const initialState = {
    all: [],
    UrlErrors: [],
  };
  
  export default function (state = initialState, action) {
    switch (action.type) {
      case 'ENCODE_URL_SUCCESS':
        return {
          ...state,
          all: action.response.data,
          UrlMessages: [action.response.data[0].shortened_url],
          UrlErrors: [],
        };
      case 'DECODE_URL_SUCCESS':
        return {
          ...state,
          all: action.response.data,
          UrlMessages: [action.response.data[0].original_url],
          UrlErrors: [],
        };
      case 'ENCODE_URL_FAILURE':
        return {
          ...state,
          UrlErrors: action.error.errors,
        };
      case 'DECODE_URL_FAILURE':
        return {
          ...state,
          UrlErrors: action.error.errors,
        };
      default:
        return state;
    }
  }
