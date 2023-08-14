// @flow
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { css, StyleSheet } from 'aphrodite';
import { encodeUrl, decodeUrl } from '../../actions/urls';
import UrlForm from '../../components/UrlForm';
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
  UrlErrors: Array<string>
}

class Home extends Component {
  static contextTypes = {
    router: PropTypes.object
  }
  props: Props
  handleEncodeURLSubmit = (data) => this.props.encodeUrl(data, this.context.router);

  handleDecodeURLSubmit = (data) => this.props.decodeUrl(data, this.context.router);

  render() {
    return (
      <div style={{ flex: '1' }}>
        <Navbar />
        <div className={`card ${css(styles.card)}`}>
          <h3 style={{ marginBottom: '2rem', textAlign: 'center' }}>Link Đây Nè</h3>
          <UrlForm onEncode={this.handleEncodeURLSubmit} onDecode={this.handleDecodeURLSubmit} 
          messages={this.props.UrlMessages} errors={this.props.UrlErrors} />
        </div>
      </div>
    );
  }
}

export default connect(
  state => ({
    urls: state.urls.all,
    UrlErrors: state.urls.UrlErrors,
    UrlMessages: state.urls.UrlMessages
  }),
  { encodeUrl, decodeUrl }
)(Home);
