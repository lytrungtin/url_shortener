const initialState = {
    all: [],
    encodeUrlErrors: [],
    decodeUrlErrors: [],
  };
  
  export default function (state = initialState, action) {
    switch (action.type) {
      case 'ENCODE_URL_SUCCESS':
        return {
          ...state,
          all: action.response.data,
          encodeUrlErrors: [],
        };
      case 'DECODE_URL_SUCCESS':
        return {
          ...state,
          all: action.response.data,
          decodeUrlErrors: [],
        };
      case 'ENCODE_URL_FAILURE':
        return {
          ...state,
          encodeUrlErrors: action.error.errors,
        };
      case 'DECODE_URL_FAILURE':
        return {
          ...state,
          decodeUrlErrors: action.error.errors,
        };
      default:
        return state;
    }
  }
