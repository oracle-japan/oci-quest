/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const endpoints = require("../endpoints");
const helpers = require("../../helpers");

/**
 * Object exposing shared access for methods required by co-dependent services
 */
module.exports = {
  getCustomer: async (req) => {
    const custId = helpers.getCustomerId(req);
    return await req.svcClient().get(`${endpoints.customersUrl}/${custId}`)
      .then(({ data }) => data);
  },

  getProduct: async (req, id) => {
    return await req.svcClient().get(`${endpoints.catalogueUrl}/catalogue/${id}`)
      .then(({ data }) => data);
  },

  getCartItems: async (req, id) => {
    return await req.svcClient().get(`${endpoints.cartsUrl}/${id}/items`)
      .then(({ data }) => data);
  },

};