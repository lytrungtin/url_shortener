// @flow
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { css, StyleSheet } from 'aphrodite';
import { encodeUrl, decodeUrl } from '../../actions/urls';
import EncodeUrlForm from '../../components/EncodeUrlForm';
import DecodeUrlForm from '../../components/DecodeUrlForm';
import Navbar from '../../components/Navbar';

const styles = StyleSheet.create({
  card: {
    maxWidth: '768px',
    margin: '2rem auto',
  },
});

type Props = {
  encodeUrl: () => void,
  decodeUrl: () => void,
  encodeUrlErrors: Array<string>,
  decodeUrlErrors: Array<string>,
}

class Home extends Component {
  static contextTypes = {
    router: PropTypes.object
  }

  componentDidMount() {
  }

  props: Props
  handleEncodeURLSubmit = (data) => this.props.encodeUrl(data, this.context.router);

  handleDecodeURLSubmit = (data) => this.props.decodeUrl(data, this.context.router);

  render() {
    return (
      <div style={{ flex: '1' }}>
        <Navbar />
        <div className={`card ${css(styles.card)}`}>
          <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Encode URL</h3>
          <EncodeUrlForm onSubmit={this.handleEncodeURLSubmit} errors={this.props.encodeUrlErrors} />
        </div>
        <div className={`card ${css(styles.card)}`}>
          <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Decode URL</h3>
          <DecodeUrlForm onSubmit={this.handleDecodeURLSubmit} errors={this.props.decodeUrlErrors} />
        </div>
      </div>
    );
  }
}

export default connect(
  state => ({
    urls: state.urls.all,
    encodeUrlErrors: state.urls.encodeUrlErrors,
    decodeUrlErrors: state.urls.decodeUrlErrors,
  }),
  { encodeUrl, decodeUrl }
)(Home);
